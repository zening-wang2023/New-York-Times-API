### Data Retrieval from the New York Times API

This repository includes a function `get_nyt_articles` designed to fetch articles from the New York Times (NYT) API. It accepts four parameters: `year`, `month`, `day`, and `api_key`. Below are the steps and methodologies used in the function:

#### Function Design
- **Input Validation**: Checks are implemented to ensure that `year`, `month`, and `day` are numeric and fall within valid ranges. The `api_key` is validated to be a string, essential for API authentication.
- **URL Construction**: Utilizes the `sprintf` function to format the date as required by the NYT API and the `glue` function to construct the request URL with query parameters.
- **Data Initialization**: Begins with an empty dataframe to store results. The initial API call is to fetch the total number of articles available for the specified date.
- **Pagination Handling**: Incorporates a repeat loop to handle API pagination, fetching 10 documents per request. For each new page, the URL is adjusted to include the page number, and data is fetched and processed.
- **Data Transformation**: Transforms the nested JSON data into a tidy dataframe using `tibble` and `tidyr`, selecting columns such as headline, byline, web_url, lead_paragraph, source, and multimedia.
- **Rate Limiting**: Includes a `Sys.sleep(6)` call within the loop to adhere to API rate limits, ensuring the function pauses for 6 seconds between requests.

#### Data Output
- Returns a dataframe containing all articles from the specified date. If no articles are available, returns an empty dataframe with NA values.

### Shiny Application for NYT Data Retrieval

This Shiny application provides a user-friendly interface for interacting with the NYT API using the `get_nyt_articles` function.

#### Library Setup
- Essential R libraries such as `shiny`, `dplyr`, and `tidyr` are loaded. The custom function `get_nyt_articles` is sourced from `midterm2.qmd`.

#### User Interface
- **UI Layout**: Implemented using `fluidPage` for a clean layout, featuring a title panel, sidebar for inputs, and a main panel for results.
- **Input Handling**: Users can input a date and their API key to fetch articles. A button initiates the data retrieval.

#### Server Logic
- **Reactive Values**: Manages application state and dynamic UI elements.
- **Error Handling**: Uses `tryCatch` to gracefully handle errors, including invalid API key notifications.
- **Dynamic Content**: Articles are listed with clickable links. Clicking a link opens a modal dialog with detailed article information.
- **Multimedia Handling**: Checks for multimedia content and displays the first image if available, with a fallback to a default NYT image.

### Installation and Usage
To run the Shiny application:
1. Clone this repository.
2. Ensure you have the required R libraries installed.
3. Run the Shiny app script provided in the repository.

This repository and the accompanying Shiny application provide a robust toolset for retrieving and displaying articles from the New York Times API, with considerations for user experience and API constraints.
