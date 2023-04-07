# Contributions
1. Saahithi Joopelli (25%)
Set up Table and Collection Views for each page
Created the three types of “Cards” used to display artist, song, and concert information
Implemented the Settings page with editable user information, including a profile picture
Implemented the Friends page with the ability to remove existing friends
Added logout and delete account options in the Settings page
2. Elizabeth Snider (25%)
Set up Table and Collection Views for each page
Created the three types of “Cards” used to display artist, song, and concert information
Implemented the Settings page with editable user information, including a profile picture
Implemented the Friends page with the ability to remove existing friends
Added logout and delete account options in the Settings page
3. Richa Gadre (25%)
Set up Spotify authorization, stored access and refresh tokens in keychain, Fetch artists and songs from API endpoint
Calculate shared songs and artists based on Spotify data
Fetch data from TicketMaster API: get events and images from API endpoint
Set up writing to, fetching from, and updating data in Firebase

4. Saran Chockan (25%)
Set up Spotify authorization, stored access and refresh tokens in keychain, Fetch artists and songs from API endpoint
Calculate shared songs and artists based on Spotify data
Fetch data from TicketMaster API: get events and images from API endpoint
Set up writing to, fetching from, and updating data in Firebase

# Deviations
We were unable to implement the ability to add friends through our app’s My Friends page and add friends from contacts during the registration process. We might end up implementing adding friends through search instead of having them automatically pull up through contacts. We are currently adding friends manually in Firebase.
We added an unforeseen feature. We used keychain to store Spotify authorization so the user does not have to authenticate every time they open the app.
We will not be implementing push notifications in our app because the data we are fetching is not real time. It doesn’t make sense to have notifications in this context.
We will be implementing the ability to add friends by the final project.
Test Account: richa@gmail.com
You will not be able to sign in on your account because your Spotify account has to be added to a Spotify allow list. Even if you were able to sign in, you would not have friends, so you would not see any meaningful data in the home screen or concerts screen.

# IMPORTANT

There are three ways to properly test the Beta. There are two reasons why we cannot support creation of accounts from your end. A) To be able to authorize the spotify account, we need to register users to the development portal. If you can send us an email with your Spotify email address, we can add you to the testing list. B) We do not have the ability to add friends yet. This is very important to see shared music and concert data. We have been testing our shared music and concert data/UI by manually adding friends to our Firebase DB. 

A) To show the full fledged functionality of our app, we can come in during office hours and show you how it works on our end. We prefer this method as there are a lot of complications that we addressed above. 

B) (Assuming you have your email register in our Spotify Developer Dashboard) You can sign in into one of our accounts and authorize your Spotify. 
username: richa@gmail.com
password: password
Your Spotify data would be merged with Richa’s spotify data but you would still be able to see your music data in the UI. 

C) You create your own account and register with your Spotify account. You will not see any data on Home and Concert as you will not have any friends to share music with. But, you will be able to see your Spotify data in your Listening Page. 


