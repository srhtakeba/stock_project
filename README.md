# CS3200 Project Report

## Abstract

In this project we set out to create a relational database of companies from the S&P 500 to gain insight on how industry, company attributes, and overall economic environment play a role in a company’s stock price. We gathered data from a relatively recent timeframe (<10 years ago) to insert into our database and make informed queries from. Our queries helped us analyze the relationship between stock and index price values and various economic environmental variables, along with how sectors are performing individually and how company’s size can influence its stock price. 


## Background & Significance

Stock indexes focus on a subset of stocks to display an overall picture of the market to investors. In this project, we focused on the S&P 500 in particular, which contains the top 500 companies, but many stock indexes are more specific in their goal to reflect a certain sector or company size for example. For investors, keeping up with these indices is vital for managing their portfolios, and specific indices can act as benchmarks to compare portfolios against. 

We also decided to add some general economic measures such as inflation, exchange rate, and expected inflation. It’s general economic knowledge that inflation increases prices, which can result in lower profit margins for companies so we were interested to see if it was reflected in our data. However, it’s also true that investors are always analyzing the market and if they feel like inflation may rise they may take action before it actually happens, which makes the stock market volatile and influenced our decision to add expected inflation as a variable. The exchange rate is important because it is correlated with the strength of the economy, and so we expect that higher exchange rates will mean higher stock prices. 

Gathering data about index performance, sector performance, and specific stock performance along with other economic variables gives us the ability to compare our previous knowledge to direct conclusions we can make from our data. We hope to both enforce what we already understand about the stock market and display some new insights that could be important to investors. We feel that understanding these relationships could assist in profile management in finance, as well as business management in general. 


## Methodology
In order to properly model our database, we have identified some main entities to represent: Stock, Company, Sector, Index Fund, and Economic Environment. We struggled initially to properly model a stock that has a fluctuating value, and we decided to separate these two into separate values, to avoid having an inappropriate number of fields for each stock. Similarly, these stock values also have a timestamp associated with them, which is part of what connects them to the economic environment table. 
We collected economic, financial, and general business data and found connections between each of these data sets to populate our model. In this way, it allows us to, for example, connect impacts of fluctuations in the economic environment, to certain sectors of businesses. 

We faced some challenges in collecting data due to differing data types and styles of records. An unanticipated hurdle we encountered was the different dates that records were kept of financial data, even if it was monthly. Some records were made on the 1st of every month, and some on the 2nd, for example. We decided to import monthly data into our database as we attempted to store daily data and were faced with extremely high run times.

Below is a model of our database:
-- insert image -- 

## Analysis
### Queries and Results

In the current state of the economy, we expected that larger-sized companies would be worth more in terms of stock price, under the assumption that a larger volume of employees correlates with company value. To test this, we queried our database, looking at the most recent available stock data, and finding the average size (no. of employees) of companies that have stock prices above average, and those below average. Below is a sample of the results from the query performed on our database (May 2023 data). 

avg_size_above_avg | avg_size_below_avg |
--- | --- |
39699.2143 | 68029.0714 |

Surprisingly, the data showed that the average size of companies with an above-average stock price is smaller than the average size for above-average stock prices. The same can be said for the stock price data in May of last year (2022) as well, showing a more significant difference in size. 
![ERD](https://github.com/srhtakeba/stock_project/assets/81027710/b010ee36-1140-470f-8eae-47e3fd14accc)

avg_size_above_avg
avg_size_below_avg
25995.6429
74880.8571

avg_size_above_avg | avg_size_below_avg |
--- | --- |
25995.6429 | 74880.8571 |

We can compare the performances between the sectors from 2018 and 2022. Energy has the highest performance increase, which makes sense as in 2018 there were severe oil price drops due to expected oversupply. In 2022 the energy sector is recovering from the slump due to the pandemic, and there has been a lot of new investment in clean energy companies due to volatile fossil fuel prices. The information tech sector has the highest performance decrease, which can be explained by high interest and inflation rates in 2022. 

-- insert image -- 

One way to look at the stability of certain stocks is to look at the price range it had in the past year. To do this, we took the maximum opening price and minimum opening price of each stock and ranked them to see the top ‘unstable’ stocks in our dataset. To see if there are trends in sectors with these unstable stocks, we also list the respective sectors of each stock. (specific to s&p 500) Below is the resulting table. 
-- insert image -- 
We compare this result to a similar calculation, this time performed on all of the sectors of stocks as we can see some themes being reflected by the result table above. 
These tables show that stocks involved in consumer discretionary goods were the most unstable in the stock market in 2022. Consumer discretionary goods are consumer goods that are not essential to the consumer including luxury goods, vacations, fast food, etc. We could attribute the instability in value in this sector as a result of the company emerging from the COVID-19 crisis. A similar reason may be behind the Health Care sector, while the reasoning behind the instability in Energy is likely to be related to conflicts in Ukraine. 
-- insert image -- 


If we query on which stocks saw the largest price changes in a day from all of our data, we can see that NVR has had some particularly severe within-day price changes. 
NVR is a company which does home-building and mortgage banking, potentially making them particularly sensitive to changes in the economy. 
-- insert image -- 


                
In order to see if monthly percent change in index price had a relationship with monthly percent change in interest rate I compared the two from 2013-2018. I didn’t notice any correlation, which is likely due to the fact that a lot more goes into this price value than just inflation, and inflation itself can have varying effects on index price depending on other economic factors. I then decided to compare the percentage change in index price to the percentage change in expected inflation, which did have a positive correlation as we can see below. This makes sense as expectations about future inflation can influence investors’ decisions. Both of the scatter plots shown below are created from importing query results to Excel.  

## Conclusions

Our database combined data from multiple different sources to create a resource that we could use to ask questions we wanted answers to concerning the stock market. Our first question on how company size related to average stock price went against our initial hypothesis, but upon further research we found that smaller companies tend to grow much faster than larger companies and can therefore have higher returns. We also analyzed sector based performance to better understand the companies within that sector, and our conclusions proved helpful in showing that in 2022, investing in Energy companies would be a good decision. Our analysis on stock price stability shows that Consumer Discretionary stocks were the most volatile, and some investors should be aware of looking at companies from this sector. We also looked at how economic factors correlate with index prices as a whole, and we can clearly see that expected inflation is generally a better indicator for price than current inflation. 

Our database is flexible in that there is enough information to ask many more questions, and we can improve our query results by updating our database with more recent data. We also decided to only include one stock index, but adding more will allow us to compare indices to answer further questions. We can also add additional economic factors in our environment table to give a better picture of the economic environment at the time frame a user is looking at. 

### References

Kuznetsov, Alexander. “S&P 500 Companies Price Dynamics” kaggle.com data sourced from Yahoo.Finance finance Python Library, May 2023. https://www.kaggle.com/datasets/alexanderkuznetsovow/s-and-p-500-companies-price-dynamics  

Osiris - The Bureau van Dijk Database by Moody’s Analytics, December 4, 2023.

Federal Reserve Bank of St. Louis, 10-Year Breakeven Inflation Rate [T10YIEM], retrieved from FRED, Federal Reserve Bank of St. Louis; https://fred.stlouisfed.org/series/T10YIEM, December 4, 2023.

Federal Reserve Bank of Cleveland, 10-Year Real Interest Rate [REAINTRATREARAT10Y], retrieved from FRED, Federal Reserve Bank of St. Louis; https://fred.stlouisfed.org/series/REAINTRATREARAT10Y, December 5, 2023.

Bank for International Settlements, Real Broad Effective Exchange Rate for United States [RBUSBIS], retrieved from FRED, Federal Reserve Bank of St. Louis; https://fred.stlouisfed.org/series/RBUSBIS, December 5, 2023.

2023 S&P Dow Jones Indices, December 4, 2023.
