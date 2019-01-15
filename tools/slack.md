# Slack

https://coreos.slack.com/messages/

## threads

https://slackhq.com/threaded-messaging-comes-to-slack

## reactions

https://slackhq.com/722-ways-to-say-i-got-your-message

## reminders

https://get.slack.help/hc/en-us/articles/208423427-Set-a-reminder#desktop-1

```
###Talk to slackbot, then the message will show up in the target person/channel
###Add new reminders
/remind #aos-svt-qe “svt-scrum starts at 9:45 https://bluejeans.com/540285617” at 9:40AM every weekday
/remind #aos-svt-qe "aos-qe-us sprint-retro starts at 21:15 https://bluejeans.com/540285617?src=calendarLink" on October 23, at 21:10PM,every 3 weeks
/remind #aos-svt-qe “@here scrum meeting with Xiaoli starts at 8:15PM” at 8:10PM
###list reminders
/remind list
```

Note that whether or not you get notifications of those reminders depends on your notification setting on the channel. We could also monify it in the way with @channel (see [here](https://get.slack.help/hc/en-us/articles/202009646-Notify-a-channel-or-workspace) for details).

## Google carlendar integration

It works but I need to figure out how to prevent others abusing the settings.
The advantage (vs remidner) of this integration is to sync automatically with Google caleanders.

## Github integrateion

https://github.com/integrations/slack

```
/github subscribe https://github.com/openshift/svt
```
