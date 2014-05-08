SafetyLookout
=============

Safety Lookout accomplishes the goal of making bike riding safer.  The cyclists wears a bluetooth headset which can monitor quick head motions (signaling a dangerous intersection), or falls.  These 'danger events' are collected for multiple cyclists across a period of time, and the data is used to map out areas which are more dangerous for cyclists.

Safety Lookout is comprised of an iOS app that interfaces with a bluetooth headset to collect data.  The iOS app then sends this data to a mongoDB backend, and information is displayed on a map dashboard. Map data can be displayed both in real-time and as a historical 'heat map' of danger zones. 

Our team focused on the use-case of a school administrator watching students ride their bike to school.  When we demoed, one team member rode his bike around the campus, and we displayed his path real time on our map, noting when he fell and when he started moving again.

This repo contains the source code for the iOS app for "Safety Lookout," which is based on the Plantronics headset sample app.

This project was accomplished as part of the AT&T Boulder Hackathon in November 2013, and was the authors first go at iOS or Objective C programming.  The team went on to win 2nd place, scoring a trip to Las Vegas during CES to re-pitch the project at the 2014 National AT&T Internet of Things Hackathon.
