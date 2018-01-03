import urllib.request
import requests
import csv
from bs4 import BeautifulSoup

url = 'https://www.data.go.kr/information/qna/index.do?currentPage=1'
# html = urllib.request.urlopen(url)
r = requests.get(url)
print(r.encoding)
soupdata = BeautifulSoup(r.content, 'html.parser')
tbody=soupdata.find('tbody')

t1 = list(tbody.stripped_strings)
m1 ={'No':[],'Title':[],'Writer':[], 'Date':[], 'Status':[]}
for string in range(len(t1)):
    if string % 5 == 0:
        m1['No'].append(t1[string])
    elif string % 5 ==1:
        m1['Title'].append(t1[string])
    elif string % 5 == 2:
        m1['Writer'].append(t1[string])
    elif string % 5 == 3:
        m1['Date'].append(t1[string])
    else:
        m1['Status'].append(t1[string])


def write_csv(text, file_name ="mining.csv"):
    output = open(file_name, "w")
    col_name = ["No", "Title", "Writer", "Date" ,"Status"]
    transfer = csv.DictWriter(output, fieldnames = col_name, delimiter=",")
    transfer.writeheader()
    for i in range(len(text['No'])):
        transfer.writerow({"No":text['No'][i], "Title": text['Title'][i], "Writer": text['Writer'][i], "Date": text['Date'][i], "Status": text['Status'][i]})
    output.close()


print(write_csv(m1))
