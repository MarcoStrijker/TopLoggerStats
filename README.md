**This project is no longer usable because TopLogger has changed and now blocks the use of their API.**

<picture align="center">
  <source media="(prefers-color-scheme: dark)" srcset="https://toploggerstats.nl/static/img/favicon_dark.svg">
  <img alt="ToploggerStats logo" src="https://toploggerstats.nl/static/img/favicon_light.svg">
</picture>

# TopLoggerStats

Welcome to the public repository of TopLoggerStats, the public web app to get insights into your climbing data. The goal of this project is to provide a simple and easy-to-use web app to get insights into your climbing data in a blazingly fast way.

I've worked on and off on this project for a few years now, and it is nice to know that several people enjoyed using it. As mentioned above, TopLogger has tightened their security policies and it prevents me from using their API. I unfortunately do not have the time to create a workaround. This means that the web app is no longer usable, and consequently, I stop working on it and make the code public.

This `README.md` file is the testament of this project. It contains the information that I would have liked to share with you when I started working on this project.

I hope you enjoy reading it :)

<br>

## The birth of the project
Driving home from a week of climbing in the Czech Republic, my friends and I were wondering if we could get better (and more) insights into our climbing journey. We wanted to know how many ascends we had logged in the year before. We all used the TopLogger app, but ascends only went back 60 days. At least, in a detailed view. I used my friend's cranky laptop and dove right into getting the data. Before we got home, I already had my own data and I wondered if I could create a simple web app to provide the same to others. My goal was for it to be blazingly fast, secure, and simple.

## General information
The application is written in Python, Cython and uses Flask as a web framework. The application is hosted on a VPS. The database is a SQLite database. The application is secured with a reverse proxy using Nginx. Frontend is written in HTML, CSS and JavaScript (jQuery).

The application is being tested by `black`, `mypy` and `radon`.

## How it got fast
Even though the application uses Flask (not the fastest framework), it is quite fast. It uses a few strategies, some small, some big, to make it fast. I've written them down, hoping one of them will inspire you.

#### Differentiating between requests
Some users started to use the application regularly. One could imagine that climbs in a gym do not change every day or week. So if the user's previous request was a few days ago, we would fetch only the climbs that are present in the requested gyms. This reduced the stress on the TopLogger API and made the application faster.

#### Cython
Most of the application logic is written in Cython. This is a compiled language that is much faster than Python. The Cython code is then imported into the Python code. This resulted in fetching data from the database, manipulating the data, and composing the rendering code taking around `0.25 seconds` for a request.

There were plans to rewrite some of the Cython code in Rust, but I never got to it.

#### Minification and other optimizations
To reduce the size of the packages sent, I minified all HTML, CSS and JavaScript code. This reduced the size of the files sent to the client by 50%. Besides this, I used `dns-prefetch` and `preconnect` in the `HTML`, as well as minified and/or slim JS libraries.

#### Caching
While I encountered a lot of issues with caching, I finally managed to get it working. The caching is done by using a local `Memcached` server. The application cached all webpages of combined views. If a user would request the same page again, the cached page was sent to the user in a dozen milliseconds.

#### ApexCharts
I started out using `plotly` to create the charts. This had two downsides: it was quite slow, since rendering is preferred from a dataframe, and it rendered server-side. The latter also meant that it was not responsive. `ApexCharts` was a much better fit. It was blazingly fast and rendered client-side.

To make it even faster, I read the `JavaScript` code from the disk and split it on delimiters. Therefore, the only thing needed to be done was to replace the variables with the actual data.

#### Database strategies
One of the first optimizations was setting up a cronjob that would prefetch all 'static' data every night. When a user requested their data, only user-specific data was fetched.

That optimization came quite early in the project; however, after a while, I started to use a lookup table for the grades and the grading system. TopLogger's internal grades are not 1:1 with every grading system, and this lookup table prevented the approximation of grades at runtime. It resulted in only a SQL join of indexes.

Later on, I overhauled the project so we only had to open a single exclusive database connection (and a small one in a different thread). This massively reduced the load time.

#### Async
For the user-related data, I used `asyncio` to make the requests. This allowed me to request the ascends data and opinions data in parallel. This easily resulted in a 30% reduction in load time.

#### Preloading
The last strategy was the use of preloading. If users selected all the necessary information in the frontend, the frontend started sending this information to the server. The server then prefetched the necessary user data. This reduced the response time of the server to a minimum.

---

While no strategies are new, I hope one of these strategies will inspire you.

Kind regards,

Marco
