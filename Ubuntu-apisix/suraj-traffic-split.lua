local core       = require("apisix.core")
local upstream   = require("apisix.upstream")
local schema_def = require("apisix.schema_def")
local roundrobin = require("resty.roundrobin")
local ipmatcher  = require("resty.ipmatcher")
local expr       = require("resty.expr.v1")
local pairs      = pairs
local ipairs     = ipairs
local type       = type
local table_insert = table.insert
local tostring   = tostring

local lrucache = core.lrucache.new({
    ttl = 0, count = 5120
})


local vars_schema = {
    type = "array",
}


local match_schema = {
    type = "array",
    items = {
        type = "object",
        properties = {
            vars = vars_schema
        }
    },
}


local upstreams_schema = {
    type = "array",
    items = {
        type = "object",
        properties = {
            upstream_id = schema_def.id_schema,
            upstream = schema_def.upstream,
            weight = {
                description = "used to split traffic between different" ..
                              "upstreams for plugin configuration",
                type = "integer",
                default = 1,
                minimum = 0
            }
        }
    },

    default = {
        {
            weight = 1
        }
    },
    minItems = 1,
    maxItems = 20
}


local schema = {
    type = "object",
    properties = {
        rules = {
            type = "array",
            items = {
                type = "object",
                properties = {
                    match = match_schema,
                    weighted_upstreams = upstreams_schema
                },
            }
        }
    },
}

local plugin_name = "suraj-traffic-split"

local _M = {
    version = 0.1,
    priority = 966,
    name = plugin_name,
    schema = schema
}

function _M.check_schema(conf)
    local ok, err = core.schema.check(schema, conf)

    if not ok then
        return false, err
    end

    if conf.rules then
        for _, rule in ipairs(conf.rules) do
            if rule.match then
                for _, m in ipairs(rule.match) do
                    local ok, err = expr.new(m.vars)
                    if not ok then
                        return false, "failed to validate the 'vars' expression: " .. err
                    end
                end
            end
        end
    end

    return true
end


local function parse_domain_for_node(node)
    local host = node.host
    if not ipmatcher.parse_ipv4(host)
       and not ipmatcher.parse_ipv6(host)
    then
        node.domain = host

        local ip, err = core.resolver.parse_domain(host)
        if ip then
            node.host = ip
        end

        if err then
            core.log.error("dns resolver domain: ", host, " error: ", err)
        end
    end
end


local function set_upstream(upstream_info, ctx)
    local nodes = upstream_info.nodes
    local new_nodes = {}
    if core.table.isarray(nodes) then
        for _, node in ipairs(nodes) do
            parse_domain_for_node(node)
            table_insert(new_nodes, node)
        end
    else
        for addr, weight in pairs(nodes) do
            local node = {}
            local port, host
            host, port = core.utils.parse_addr(addr)
            node.host = host
            parse_domain_for_node(node)
            node.port = port
            node.weight = weight
            table_insert(new_nodes, node)
        end
    end

    local up_conf = {
        name = upstream_info.name,
        type = upstream_info.type,
        hash_on = upstream_info.hash_on,
        pass_host = upstream_info.pass_host,
        upstream_host = upstream_info.upstream_host,
        key = upstream_info.key,
        nodes = new_nodes,
        timeout = upstream_info.timeout,
    }

    local ok, err = upstream.check_schema(up_conf)
    if not ok then
        core.log.error("failed to validate generated upstream: ", err)
        return 500, err
    end

    local matched_route = ctx.matched_route
    up_conf.parent = matched_route
    local upstream_key = up_conf.type .. "#route_" ..
                         matched_route.value.id .. "_" .. upstream_info.vid
    if upstream_info.node_tid then
        upstream_key = upstream_key .. "_" .. upstream_info.node_tid
    end
    core.log.error("upstream_key: ", upstream_key)
    core.log.error("up_conf: ", up_conf)
    upstream.set(ctx, upstream_key, ctx.conf_version, up_conf)

    return
end


local function new_rr_obj(weighted_upstreams)
    local server_list = {}
    for i, upstream_obj in ipairs(weighted_upstreams) do
        if upstream_obj.upstream_id then
            server_list[upstream_obj.upstream_id] = upstream_obj.weight
        elseif upstream_obj.upstream then

            upstream_obj.upstream.vid = i

            local node_tid = tostring(upstream_obj.upstream.nodes):sub(#"table: " + 1)
            upstream_obj.upstream.node_tid = node_tid
            server_list[upstream_obj.upstream] = upstream_obj.weight
        else

            upstream_obj.upstream = "plugin#upstream#is#empty"
            server_list[upstream_obj.upstream] = upstream_obj.weight

        end
    end

    return roundrobin:new(server_list)
end


function _M.access(conf, ctx)
    if not conf or not conf.rules then
        return
    end

    local weighted_upstreams
    local match_passed = true

    for _, rule in ipairs(conf.rules) do
        if not rule.match then
            match_passed = true
            weighted_upstreams = rule.weighted_upstreams
            break
        end

        for _, single_match in ipairs(rule.match) do
            local expr, err = expr.new(single_match.vars)
            if err then
                core.log.error("vars expression does not match: ", err)
                return 500, err
            end

            match_passed = expr:eval(ctx.var)
            if match_passed then
                break
            end
        end

        if match_passed then
            weighted_upstreams = rule.weighted_upstreams
            break
        end
    end

    core.log.error("match_passed: ", match_passed)

    if not match_passed then
        return
    end

    local rr_up, err = lrucache(weighted_upstreams, nil, new_rr_obj, weighted_upstreams)
    if not rr_up then
        core.log.error("lrucache roundrobin failed: ", err)
        return 500
    end

    local upstream = rr_up:find()
    if upstream and type(upstream) == "table" then
        core.log.info("upstream: ", core.json.encode(upstream))
        return set_upstream(upstream, ctx)
    elseif upstream and upstream ~= "plugin#upstream#is#empty" then
        ctx.upstream_id = upstream
        core.log.info("upstream_id: ", upstream)
        return
    end

    ctx.upstream_id = nil
    core.log.error("route_up: ", upstream)
    return
end


return _M
