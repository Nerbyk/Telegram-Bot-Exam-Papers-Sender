# Telegram Bot for examiantion paper sending

Every foreigner arriving from the CIS to the Czech Republic must pass nostrification exams. 3 to 6 exams are assigned.
Russian-speaking community in Brno(Pozor! Brno) organizes free assistance for new arrivals by providing them with examination papers(from 20 to 30 themes)
based on subjects that were assigned to new arrivals. But some people started selling this papers, so the access to this papers must be restricted.
So this bot sends the necessary documents with examinations papers based on the information provided by the user after after the administrator approves the application.

## User Panel

* Send contact details(name surname, social network link)
* Send list of subjects which were assigned
* Send a photo of the invitation to the exam from the ministry, where the list of objects
* Check status of application
* Get files if accepted/ rejection reason

## Admin Panel
* Check user's application in sequence
* Restrict access to bot for specific users(spam and so on)
* Accept/Refuse a request

## Features
* Data storing in SQLite3
* Logging errors
* Parsing group members from VK(russian facebook)(in progress)
* Separate classes for all the functional(in progress)
