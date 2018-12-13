# DosProject4B

## Installation & Initialisation details
To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## To run the project
mix phx.server

## Description
For this project, we utilised Phoenix framework to create a web application that would provide a simulation of
the ongoing bitcoin mining and transactions. To provide the simulation results we made use of Phoenix's MVC
architecture to design layouts, web pages and the controllers necessary to communicate with the back-end and
relay the information back to the front-end. 

The web application covered two important aspects:
1. Displaying on-going simulations by means of a chart & dashboard
2. An interface for transacting bitcoins 

Part I:
(This deals with the UI for the regular implementation)
The following charts were displayed:
	1. Number of successful transactions
	2. Number of failed transactions
	3. Number of blocks mined
	4. Total bitcoins in network
	5. Average wallet balance per user

Dashboard displays following metrics:
	- Transaction ID
	- Amount transacted
It shows upto 50 transactions row-wise, that get updated after every 5s.

Part II:
(This deals with the UI for bonus implementation)
This displays a form for initialising & confirming a transaction, upon validation
The flow is as follows -
	- Select sender & receiver public keys
	- Upon selecting sender public key, sender's wallet balance is displayed.
	- Enter chosen transaction amount
	- Sign and Confirm transaction
	- View Signature, generated transaction ID & Status of confirmed transaction
