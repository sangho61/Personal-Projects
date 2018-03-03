import logging
import sys
import pandas as pd

class DataProcessor(object):
    # director, revenue, genre column numbers in the data frame
    dir_pos = 8
    rev_pos = 20
    genre_pos = 13

    def __init__(self, data_path):
        with open(data_path, 'r') as file:
            self.movie_data = pd.read_csv(file, header=0)
            # logging.debug(self.movie_data)

    def wrangle_data(self):
        self.__genre_revenue()

    def __genre_revenue(self):
        genre_revenue = {}
        # for each genre, calculate avg revenue
        for index, row in self.movie_data.iterrows():
            genres = row["genres"]
            try:
                genres_list = genres.split("|")
            except:
                genres_list = []
                logging.error("Genre reading error")
            revenue = row["revenue_adj"]
            for genre in genres_list:
                if genre not in genre_revenue:
                    total_revenue = revenue
                    count = 1
                else:
                    total_revenue = genre_revenue[genre][0]
                    total_revenue += revenue
                    count = genre_revenue[genre][1]
                    count += 1
                genre_revenue[genre] = (total_revenue, count)
                logging.debug(genre_revenue)


if __name__ == '__main__':
    logging.basicConfig(stream=sys.stderr, level=logging.DEBUG)
    my_proc = DataProcessor("../TMDb/tmdb-movies.csv")
    my_proc.wrangle_data()
