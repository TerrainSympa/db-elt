# Small script to just check what are the most popular dataset
import pandas as pd


if __name__ == '__main__':
    data = pd.read_csv("data/export-dataset-20210814-074535.csv", sep=';')
    print(data.columns)
    data_followers = data.sort_values("metric.followers", ascending=False)
    data_views = data.sort_values("metric.views", ascending=False)
    print('--------------FOLLOWERS--------------')
    for i in range(50):
        print(data_followers.iloc[i]['title'], data_followers.iloc[i]['metric.followers'], data_followers.iloc[i]['url'])
    print('--------------VIEWS--------------')
    for i in range(50):
        print(data_views.iloc[i]['title'], data_views.iloc[i]['metric.views'], data_views.iloc[i]['url'])

