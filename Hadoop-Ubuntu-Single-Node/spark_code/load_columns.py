



def main():
    # Python program to read
    # json file
    import pandas
    df = pandas.read_csv('table_columns.csv')
    df = df[(df['TABLE_NAME'] == 'DS_ALL_LOGINS_EVENTS')]
    print(df)
    df_list = df['COLUMN_NAME'].tolist()
    print(df_list)

    import sys
    sys.exit()

main()