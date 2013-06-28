Poppins
=======

A personal habit, routine, and schedule manager created to help me manage several ADHD issues at once. Poppins is my nanny/governess.

Changing habits is hard. 
Over time, they become hardened neural pathways in our brains and almost literally require rewiring. 
What's more, going against our default behavior (habitual response) saps our willpower.
Poppins is an attempt to change multiple habits at once, mitigating the negative effects, rewarding successes, punish failures, and help others support my (your) efforts.

Poppins is meant to tie several systems together: Find My iPhone, RescueTime, the Twist app, Google Calendar, and anything else that can be integrated with less effort than it'd take to build.

The easiest way to describe Poppins is by walking you through a day using Poppins:

**AM**
- 8:30     Alarm on phone goes off, but I don't hear it.
- 8:40     Poppins detects that I haven't used my phone yet, so sends a different & louder alarm until I do.
- 8:40:05  I shoot up awake, both thankful for and cursing the existence of Poppins.
- 8:41     Poppins messages me: "Good morning! You've got about 30 minutes left before you need to have started your morning walk."
- 8:56     Poppins messages me: "Just a heads-up that you've got 15 minutes left to start walking...or else!"
- 9:00     I go outside and start walking around the block, which Poppins detects because I've geofenced my home.
- 9:10     Poppins: "You finished your walk...congrats! You can head home now & start the day."
...
- 11:20    Poppins: "You've been reading Hacker News for 10 minutes now. Time to get back to work."
- 11:25    Poppins: "Since you're still slacking, I'm locking your phone & only letting you access Stack Overflow and Google search results for the next hour."

**PM**
- 2:00     Poppins messages me letting me know I have a meeting in an hour, who it's with, where it's at, and that I need to leave by 2:30 to be on time.
- 2:15     Poppins: "Time to pack up & get ready to leave for your meeting!" 
- 2:16     Poppins sends remote command to laptop to hibernate & locks my phone.
- 2:35     Poppins detects I still haven't left yet, sends a message to who I'm meeting with to let them know I'm running late.
...
- 6:30     Poppins: "Time to make dinner and eat!"
...
- 11:00    Poppins: "Time to shut down everything and get ready for bed!"
- 11:05    Poppins hibernates laptop and locks the phone.
...
- 2:00A    Poppins detects laptop or phone is being used & responds by sending hibernate/lock command.

# Components

## Server
- Find My iPhone API wrapper to message/track user and lock iPhone (eg. Sosumi or any of its ports: [PHP](https://github.com/tylerhall/sosumi/), [python](https://github.com/pearkes/findi/), [Ruby](https://github.com/hpop/rosumi))
- Google Calendar API client to know schedule
- RescueTime API to detect when getting distracted
- Task Scheduler that supports scheduling with recurrences and/or intervals

## Client
- Something to run in Windows 7 that will allow server to restrict browsing, as well as application execution
