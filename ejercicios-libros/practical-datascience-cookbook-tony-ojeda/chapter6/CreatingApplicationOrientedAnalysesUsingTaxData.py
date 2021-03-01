import numpy as np
import jinja2
import numpy.ma as ma
import matplotlib.pyplot as plt
import csv

data_file = "D:\Google Drive\projects\practical-datascience-cookbook-tony-ojeda\chapter6\income_dist.csv"

with open(data_file, 'r') as csvfile:
    reader = csv.DictReader(csvfile)
    data = list(reader)
    
len(data)

print reader.fieldnames

len(reader.fieldnames)

def dataset(path):
    with open(path, 'r') as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            yield row


print set([row["Country"] for row in dataset(data_file)])

#Inspect the range of years in dataset
print min(set([int(row["Year"]) for row in dataset(data_file)]))
print max(set([int(row["Year"]) for row in dataset(data_file)]))

{row["Country"] for row in dataset(data_file)}

#filter data just for united states
filter(lambda row: row["Country"] == "United States", dataset(data_file))


def dataset(path, filter_field=None, filter_value=None):
    with open(path, 'r') as csvfile:
        reader = csv.DictReader(csvfile)
        if filter_field:
            for row in filter(lambda row: row[filter_field]==filter_value, reader):
                yield row
        else:
            for row in reader:
                yield row

def main(path):
    data = [(row["Year"], float(row["Average income per tax unit"]))
    
        for row in dataset(path, "Country", "United States")]
        
    width = 0.35
    ind = np.arange(len(data))
    fig = plt.figure()
    ax = plt.subplot(111)
    ax.bar(ind, list(d[1] for d in data))
    ax.set_xticks(np.arange(0, len(data), 4))
    ax.set_xticklabels(list(d[0] for d in data)[0::4], rotation=45)
    ax.set_ylabel("Income in USD")
    plt.title("U.S. Average Income 1913-2008")
    plt.show()
        
if __name__ == "__main__":
    main("income_dist.csv")
        
        
dataset = np.recfromcsv(data_file, skip_header=1)
dataset
dataset.size
dataset.shape

names = ["country", "year"]
names.extend(["col%i" % (idx+1) for idx in xrange(352)])
dtype = "S64,i4," + ",".join(["f8" for idx in xrange(352)])


dataset = np.genfromtxt(data_file, dtype=dtype, names=names, delimiter=",", skip_header=1, autostrip=2)


ma.masked_invalid(dataset['col1'])

#Analyzing and visualizing the top income data of the US

#-----------------helpers
#Extract the data for the country provided. Default is United States.
def dataset(path, country="United States"):

    with open(path, 'r') as csvfile:
        reader = csv.DictReader(csvfile)
        for row in filter(lambda row: row["Country"]==country, reader):
            yield row

#Creates a year based time series for the given column.
def timeseries(data, column):

    for row in filter(lambda row: row[column], data):
        yield (int(row["Year"]), row[column])

#wraps matplotlib and generates a line chart for each time series that is passed to it:
def linechart(series, **kwargs):
    fig = plt.figure()
    ax = plt.subplot(111)

    for line in series:
        line = list(line)
        xvals = [v[0] for v in line]
        yvals = [v[1] for v in line]
        ax.plot(xvals, yvals)
        if 'ylabel' in kwargs:
            ax.set_ylabel(kwargs['ylabel'])
        if 'title' in kwargs:
            plt.title(kwargs['title'])
        if 'labels' in kwargs:
            ax.legend(kwargs.get('labels'))
    return fig    

#Create Income Share chart
def percent_income_share(source):

    columns = (
        "Top 10% income share",
        "Top 5% income share",
        "Top 1% income share",
        "Top 0.5% income share",
        "Top 0.1% income share",
    )
    source = list(dataset(source))
    
    return linechart([timeseries(source, col) for col in columns], 
                      labels=columns,
                      title="U.S. Percentage Income Share",
                      ylabel="Percentage")

#Normalizes the data set. Expects a timeseries input
def normalize(data):

    data = list(data)
    norm = np.array(list(d[1] for d in data), dtype="f8")
    mean = norm.mean()
    norm /= mean
    
    return zip((d[0] for d in data), norm)



#compute mean normalized series
def mean_normalized_percent_income_share(source):
    
    columns = (
                "Top 10% income share",
                "Top 5% income share",
                "Top 1% income share",
                "Top 0.5% income share",
                "Top 0.1% income share",
                )
    
    source = list(dataset(source))
    
    return linechart([normalize(timeseries(source, col)) for col in columns],
                    labels=columns,
                    title="Mean Normalized U.S. Percentage Income Share",
                    ylabel="Percentage")


# compute the difference between two columns and plot the resulting time series
#Returns an array of deltas for the two arrays.
def delta(first, second):

    first = list(first)
    years = yrange(first)
    first = np.array(list(d[1] for d in first), dtype="f8")
    second = np.array(list(d[1] for d in second), dtype="f8")
    # Not for use in writing
    if first.size != second.size:
        first = np.insert(first, [0,0,0,0], [None, None, None,
    None])
    diff = first - second
    return zip(years, diff)

#Get the range of years from the dataset
def yrange(data):

    years = set()
    for row in data:
        if row[0] not in years:
            yield row[0]
            years.add(row[0])
            

#Computes capital gains lift in top income percentages over time chart
def capital_gains_lift(source):

    columns = (
                ("Top 10% income share-including capital gains", "Top 10% income share"),
                ("Top 5% income share-including capital gains", "Top 5% income share"),
                ("Top 1% income share-including capital gains", "Top 1% income share"),
                ("Top 0.5% income share-including capital gains", "Top 0.5% income share"),
                ("Top 0.1% income share-including capital gains", "Top 0.1% income share"),
                ("Top 0.05% income share-including capital gains", "Top 0.05% income share"),
                )
    source = list(dataset(source))
    series = [delta(timeseries(source, a), timeseries(source, b)) for a, b in columns]
    
    return linechart(series,labels=list(col[1] for col in
                    columns), title="U.S. Capital Gains Income Lift",
                    ylabel="Percentage Difference")            

#Compares percentage average incomes
def average_incomes(source):

    columns = (
                "Top 10% average income",
                "Top 5% average income",
                "Top 1% average income",
                "Top 0.5% average income",
                "Top 0.1% average income",
                "Top 0.05% average income",
                )
    source = list(dataset(source))
    
    return linechart([timeseries(source, col) for col in
                    columns], labels=columns, title="U.S. Average Income",
                    ylabel="2008 US Dollars")


#Compares top percentage avg income over total avg
def average_top_income_lift(source):

    columns = (
        ("Top 10% average income", "Top 0.1% average income"),
        ("Top 5% average income", "Top 0.1% average income"),
        ("Top 1% average income", "Top 0.1% average income"),
        ("Top 0.5% average income", "Top 0.1% average income"),
        ("Top 0.1% average income", "Top 0.1% average income"),
        )
    
    source = list(dataset(source))
    series = [delta(timeseries(source, a), timeseries(source, b)) for a, b in columns]
    
    return linechart(series, labels=list(col[0] for col in columns),
                    title="U.S. Income Disparity",
                    ylabel="2008 US Dollars")


def stackedarea(series, **kwargs):
    
    fig = plt.figure()
    axe = fig.add_subplot(111)
    fnx = lambda s: np.array(list(v[1] for v in s), dtype="f8")
    yax = np.row_stack(fnx(s) for s in series)
    xax = np.arange(1917, 2008)
    polys = axe.stackplot(xax, yax)
    axe.margins(0,0)
    
    if 'ylabel' in kwargs:
        axe.set_ylabel(kwargs['ylabel'])
    if 'labels' in kwargs:
        legendProxies = []
        for poly in polys:
            legendProxies.append(plt.Rectangle((0, 0), 1, 1, fc=poly.get_facecolor()[0]))
        axe.legend(legendProxies, kwargs.get('labels'))
    if 'title' in kwargs:
        plt.title(kwargs['title'])
    
    return fig

#Compares income composition
def income_composition(source):

    columns = (
                "Top 10% income composition-Wages, salaries and pensions",
                "Top 10% income composition-Dividends",
                "Top 10% income composition-Interest Income",
                "Top 10% income composition-Rents",
                "Top 10% income composition-Entrepreneurial income",
                )       
    
    source = list(dataset(source))
    labels = ("Salary", "Dividends", "Interest", "Rent", "Business")
    
    return stackedarea([timeseries(source, col) for col in 
                        columns], labels=labels,
                        title="U.S. Top 10% Income Composition",
                        ylabel="Percentage")
#------------------


percent_income_share(data_file)
plt.show()

mean_normalized_percent_income_share(data_file)
plt.show()

capital_gains_lift(data_file)
plt.show()

#Furthering the analysis of the top income groups of the US
average_incomes(data_file)
plt.show()

average_top_income_lift(data_file)
plt.show()


income_composition(data_file)

#-------------------------jinja2
from jinja2 import Template

template = Template('Greetings, {{ name }}!')
template.render(name='Mr. Martin')

from jinja2 import Environment, PackageLoader, FileSystemLoader

dir_temp = "D:\Google Drive\projects\practical-datascience-cookbook-tony-ojeda\chapter6\templates"
jinjaenv = Environment(loader = FileSystemLoader('templates'))
template = jinjaenv.get_template('report.html')

#example
import csv
import json

from datetime import datetime
from jinja2 import Environment, PackageLoader, FileSystemLoader
from itertools import groupby
from operator import itemgetter

def dataset(path, include):
    
    column = 'Average income per tax unit'
    with open(path, 'r') as csvfile:
        reader = csv.DictReader(csvfile)
        key = itemgetter('Country')
    
        # Use groupby: memory efficient collection by country
        for key, values in groupby(reader, key=key):
            # Only yield countries that are included
            if key in include:
                yield key, [(int(value['Year']), float(value[column]))
                    for value in values if value[column]]


def extract_years(data):
    
    for country in data:
        for value in country[1]:
            yield value[0]

def extract_series(data, years):
    
    for country, cdata in data:
        cdata = dict(cdata)
        series = [cdata[year] if year in cdata else None for year in years]
        yield {
        'name': country,
        'data': series,
        }

def write(context):
    
    path = "report-%s.html" %datetime.now().strftime("%Y%m%d")
    jinjaenv = Environment(loader = FileSystemLoader('templates'))
    template = jinjaenv.get_template('report.html')
    template.stream(context).dump(path)

def main(source):
    # Select countries to include
    include = ("United States", "France", "Italy", "Germany", "South Africa", "New Zealand")

    # Get dataset from CSV
    data = list(dataset(source, include))
    years = set(extract_years(data))

    # Generate context
    context = {
    'title': "Average Income per Family, %i - %i" %(min(years), max(years)),
    'years': json.dumps(list(years)),
    'countries': [v[0] for v in data],
    'series': json.dumps(list(extract_series(data, years))),
    }

    # Write HTML with template
    write(context)

if __name__ == '__main__':
    source = data_file
    main(source)



























