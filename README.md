### Getting data from the API

I designed the function get_nyt_articles to accept four parameters: year, month, day, and api_key. I incorporated input validation to ensure that the year, month, and day are numeric and within appropriate ranges. Moreover, I made sure that the api_key provided is a character string since this is a prerequisite for authentication with the NYT API.

In order to better corporate with the API, I formatted the date using sprintf to match the API's required format. I then used the glue function to build the request URL, incorporating the formatted date and API key into the query parameters. This URL serves as the base from which I make my GET requests to the NYT API.

Before diving into the data retrieval, I initialized an empty data frame to store the articles. The first API call, made using the base URL, helps me determine the total number of articles (hits) available for the given date. If there are no articles, my function returns an empty data frame populated with NA to indicate the absence of data.

Each API request will return only 10 documents at a time, so I also set up a repeat loop to iterate over each page of results. Within this loop, I generate a new URL for each page by appending the page number to the base URL. I fetch the data and then transform it from a nested JSON structure into a tidy dataframe. I make use of tibble and tidyr to unnest the articles and select the relevant columns: headline, byline, web_url, lead_paragraph, source, and multimedia.

I concatenate the results of each page to the initial data frame using rbind. To determine when to exit the loop, I compare the cumulative number of articles retrieved against the hits value. If I've retrieved all available articles, the loop terminates.

It's worth noting that to maintain good standing with the NYT API and avoid overwhelming their servers, I included a Sys.sleep(6) call at the end of each loop iteration. This ensures that my function pauses for 6 seconds between requests, adhering to the API's rate limit policies.

Finally, the function returns a comprehensive dataframe containing all the articles for the specified date. This data is ready to be analyzed or stored for future use.

------------------------------------------------------------------------
  
  ### Shiny Front End
  
  I started by setting the necessary R libraries, ensuring all functions and methods required were at my disposal. Libraries like shiny, dplyr, and tidyr are among the essentials that lay the groundwork for both the UI and the backend processing.

I also use source to make my get_nyt_articles function from midterm2.qmd available to my shiny app.

The UI of my application is straightforward. I used fluidPage to establish a clean layout, which includes a title panel, a sidebar for inputs, and a main panel for displaying results. Users can input a date and their API key, then initiate the search with a simple button click.

On the server side, I crafted the logic to respond to the user's requests. I incorporated reactive values to manage the state of the application, particularly for handling dynamic UI elements like the article links. When a search is initiated, I make sure to clear any previous observers to prepare for the new batch of data.

I wrapped the API call within a tryCatch block to gracefully handle any potential warnings or errors. This includes checking for an 'Unauthorized' warning, which indicates an invalid API key. In such cases, I inform the user to verify their credentials and try again.

Upon successfully retrieving articles, I dynamically generate UI elements for each one. I employed lapply to create rows containing clickable links that display the article headlines. For each link, I create an observer that, upon activation, presents a modal dialog with more details about the article. This includes the byline, lead paragraph, and a link to the full article.

Notably, I included a feature that enriches the modal with the first image from each article, if available. My function checks if there's multimedia content and, if so, constructs the image URL to display it. If there's no image, a default NYT image is shown instead.
