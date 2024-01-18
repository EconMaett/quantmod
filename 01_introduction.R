# quantomod ----

# Quantitative Financial Modelling & Trading Framework for R 

# Website: http://www.quantmod.com/

# quantmod_0.4.25 on CRAN
# https://blog.fosstrading.com/2023/08/quantmod-0-4-25-on-cran/

# GitHub: https://github.com/joshuaulrich/quantmod


# xts: https://joshuaulrich.github.io/xts/index.html


## Installation ----

# The package is on CRAN
# install.packages("quantmod")

library(quantmod)

# The main function of the `quantmod` package is `getSymbols()`.

help("getSymbols")

# The function allows you to load financial data from various
# Sources, such as
# Yahoo Finance, Google, FRED,
# FX, Metals, etc.


## 1 - The S&P 500 index ----

# We use a separate environment which we call `sp500` to store the
# downloaded data.

# We first create the environment:
sp500 <- new.env()

# We then download the S&P 500 time series (symbol: ^GSPC)
# from 1960 to 2009-01-01 from Yahoo Finance via:
getSymbols(
  Symbols = "^GSPC",
  env = sp500,
  src = "yahoo",
  from = as.Date("1960-01-04"),
  to = as.Date("2009-01-01")
)
# "GSPC"

# The `quantmod` package can accwss various sources.

# Currently available are:
# - yahoo
# - google
# - MySQL
# - FRED
# - csv
# - RData
# - oandata


# There are now several ways to load the object called "GSPC"
# from the environment `sp500` into the global environment.

GSPC <- sp500$GSPC
GSPC1 <- get("GSPC", envir = sp500)
GSPC2 <- with(sp500, expr = GSPC)

head(GSPC)
head(GSPC1)
head(GSPC2)

# The objects are identical and we remove the latter two
rm(GSPC1)
rm(GSPC2)


head(GSPC)
# This is an OHLC time series with at least the daily
# Open, High, Low, and Close prices for the ticker symbol GSPC.
# It also contains the traded volumne and the closing price
# adjusted for corporate events such as dividends or splits.

# The data object is an `xts` object, which stands for
# extensible time series.

class(GSPC)
# "xts" "zoo"


# It is a multivariate (ireegular) time series
dim(GSPC)
# 12334 x 6


# We can extract variables with the dollar operator `$`
head(GSPC$GSPC.Volume)

# `xts` objects can be filtered by ISO 8601 date-time formats
# YYYY-MM-DD HH:MM:SS

# Get al observations for March 1970:
head(GSPC["1970-03"])


# Specify a range of time stamps with slashes `/`:

# Get all observations upt to Epiphany (January 6) in 1060:

head(GSPC["/1960-01-06"])


# Get all observations from Christmas Day (December 25) in 2008 onwards
head(GSPC["2008-12-25/"])


# The `quantmod` package provides convenience column extractors
# such as `Cl()` for the closing price,
# `OpCl()` for the transformation from opening to closing prices
# `ClCl()` for the changes in closing prices:

head(Cl(GSPC))
# GSPC.Close


head(OpCl(GSPC))
# OPCl.GSPC


head(ClCl(GSPC))
# ClCl.GSPC


# The generic function `plot()` has a convenient method defined
# for `xts` objects
plot(GSPC, multi.panel = TRUE, yaxis.same = FALSE)

png("gspc-ohlc.png")

dev.off()


# You can also plot the series with the
# function `chartSeries()`
chartSeries(GSPC)
png("gspc-chart.png")

dev.off()

chart_Series(GSPC)
png("gspc-chart2.png")

dev.off()


# The function `chartSeries()` provides a candlestick
# plot for OHLC data.

# You will see this when you zoom in
chartSeries(GSPC["2008-12"])
png("gspc-candlestick.png")
dev.off()


# Assuminng we are interested in the daily values of the weekly
# last-traded-day,
# we aggregate with the appropriate function from the
# zoo Quick Reference.

# Since `xts` objects inherit from the `zoo` class,
# `zoo` methods naturally work on `xts` objects as well.


# The convenience function `nextfri()` computes for each
# "Date" the next Friday:
nextfri <- function(x) 7 * ceiling(as.numeric(x - 5 + 4) / 7) + as.Date(5 - 4)

# We get the aggregated data via
SP.we <- aggregate(GSPC, nextfri, tail, 1)

# The function `stats::aggregate()` splits the data into subsets
# - here according to the function `nextfri()` - 
# and computes statistics for each, i.e. takes the last value,
# which we obtain with `tail(n = 1)`.


# This works because "GSPC" is of class "eXtensible Time Series" or
# `xts`, which inherits from the class `zoo`, 
# or "Z's Ordered Observations".

# The `nextfri()` method is defined for the `zoo` class.

# However, we lose the `xts` class if we aggregate this way.
class(SP.we)
# "zoo"


# We can simply use the `xts::xts()` function to convert a 
# `zoo` object onto an `xts` object:
SP.we <- xts(aggregate(GSPC, nextfri, tail, 1))

class(SP.we)
# "xts" "zoo"

# This preserves the `xts` class.


# Alternatively, we use `xts::apply.weekly()`
SP.we <- xts::apply.weekly(GSPC, FUN = tail, 1)

head(SP.we)

class(SP.we)
# "xts" "zoo"

# We extract the closing prices for the last trading day 
# in every week:
SPC.we <- Cl(SP.we)

# and plot this time series
plot(SP.we)
png("gspc-friday-close.png")
dev.off()


# We can create log-returns manually
lr <- diff(log(SPC.we))
plot(lr)

png("gspc-lr.png")
dev.off()


# Or we use 
# - `quantmod::periodReturn()` 
# - `quantmod::weeklyReturn()`
# with type = "log"

head(weeklyReturn(Cl(GSPC), type = "log"))

head(lr)

# Note that we have aplied a log approximation whereas
# the in-built functions use the appropriate formulas.


## 2 - Investigating the NASDAQ-100 index ----

# We want to analyze the
# National Association of Securities Dealers Automated Qutations
# (NASDAQ)

# We access
# https://www.nasdaq.com/market-activity/quotes/nasdaq-ndx-index?render=download
# To download data in CSV files.

# Some companies appear with two symbols,
# so there will be more than 100 entries.

# The Nasdaq-100 (^NDX[2]) is a stock market index made up of 
# 101 equity securities issued by 100 of the largest
# non-financial companies listed on the Nasdaq stock exchange. 

nasdaq100 <- read.csv(
  file = "nasdaq100list.csv", 
  stringsAsFactors = FALSE, 
  strip.white = TRUE
  )

head(nasdaq100)

dim(nasdaq100)
# 75 x 11
# (the composition changes over time)

colnames(nasdaq100)
names(nasdaq100)
# Symbol, Name, Last.Sale, Net.Change, X..Change,
# Market.Cap, Country, IPO.Year, Volume, Sector, Industry

nasdaq100$Name[duplicated(nasdaq100$Name)]
# There are currently no duplicates

# We use `quantmod::getSymbols()` and store the NASDAQ-100
# data in a separate environment.
nasdaq <- new.env()

# We use `tryCatch()` to handle unusual conditions and errors,
# like if the data from a company are not available
# from yahoo finance, the message
# "Symbol ... not downloadable!"
# is given.

# For simplicity, we only download symbols starting with
# the letter "A"

for (i in nasdaq100$Symbol[startsWith(nasdaq100$Symbol, "A")]) {
  
  cat("Downloading time series for symbol '", i, "' ...\n", sep = "")
  
  status <- tryCatch(expr = getSymbols(i, env = nasdaq, src = "yahoo", from = as.Date("2000-01-01")), error = identity)
  
  if(inherits(status, what = "error")) cat("Symbol '", i, "' not downloadable!\n", sep = "")
}


# The first values of the Apple time series are
with(nasdaq, expr = head(AAPL))


# The `quantmod::chartSeries()` function is useful here
chartSeries(nasdaq$AAPL)
png("aapl-chart.png")
dev.off()


# Visualize the On-Balance volume
chartSeries(nasdaq$AAPL)
with(nasdaq, addOBV(AAPL))
png("aapl-obv.png")
dev.off()

# Check out the quantmod manual for a list
# of all possible visualization functions.

# For example, Bollinger bands consist of a center line and two
# price channels (bands) above and below it.

# The center line is an exponential moving average,
# the price channels are the standard deviations of 
# the stock being studied.

# The bands will expand and contract as the price
# action of an issue becomes volatile (expansion)
# or becomes bound into a tight trading pattern (contraction).

# Add Bollinger Bands with 
# `quantmod::addBBands(n = 20, sd = 2, ma = "SMA", draw = "bands", on = -1)`
# Where n denotes the number of moving average periods,
# sd the number of standard deviations
# and ma the used moving average process.

chartSeries(nasdaq$AAPL)
# with(nasdaq, addOBV(AAPL))
addBBands(n = 20, sd = 2, ma = "SMA", draw = "bands", on = -1)
png("aapl-bbands.png")
dev.off()
