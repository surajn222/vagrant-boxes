from flask import Flask, request, jsonify
app = Flask(__name__)

@app.route('/')
def hello_world():
  return 'Test'

@app.route('/test')
def test():
  return 'Test1'

@app.route('/spark', methods=['POST'])
def foo():
    data = request.json
    print("HW")
    print(data)
    return jsonify(data)

@app.route('/spark/status', methods=['GET'])
def bar():
    data = request.json
    print("HW")
    print(data)
    return jsonify(data)


if __name__ == '__main__':
  app.run(debug=True)