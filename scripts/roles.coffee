# Assign roles to people you're chatting with
#
# <user> is a badass guitarist - assign a role to a user
# <user> is not a badass guitarist - remove a role from a user
# who is <user> - see what roles a user has

# hubot holman is an ego surfer
# hubot holman is not an ego surfer
#

module.exports = (robot) ->

  getAmbiguousUserText = (users) ->
    "Be more specific, I know #{users.length} people named like that: #{(user.name for user in users).join(", ")}"

  usersForRawMentionName = (mentionName) ->
    console.log("usersForRawMentionName 0", mentionName)
    lowerMentionName = mentionName.toLowerCase()
    console.log("usersForRawMentionName 1", lowerMentionName)

    user for key, user of (robot.users() or {}) when (
      user.name.toLowerCase().lastIndexOf(lowerMentionName, 0) == 0 or
      user.mention_name.toLowerCase().lastIndexOf(lowerMentionName, 0) == 0)

  usersForMentionName = (mentionName) ->
    matchedUsers = usersForRawMentionName(mentionName)
    lowerMentionName = mentionName.toLowerCase()

    console.log("usersForMentionName 0", lowerMentionName)

    for user in matchedUsers
      return [user] if user.name.toLowerCase() is lowerMentionName or
      user.mention_name.toLowerCase() is lowerMentionName

    matchedUsers

  robot.respond /who is @?([\w -_]+)\?*$/i, (msg) ->
    name = msg.match[1].trim()
    console.log("who is", name)

    if name is "you"
      msg.send "Who ain't I?"
    else if name.toLowerCase() is robot.name.toLowerCase()
      msg.send "The best."
    else
      users = usersForMentionName(name)
      if users.length is 1
        user = users[0]
        user.roles = user.roles or [ ]
        if user.roles.length > 0
          msg.send "@#{user.mention_name} is #{user.roles.join(", ")}."
        else
          msg.send "@#{user.mention_name} is nothing to me."
      else if users.length > 1
        msg.send getAmbiguousUserText users
      else
        msg.send "#{name}? Never heard of 'em"

  robot.respond /@?([\w .-_]+) is (["'\w -_]+)[.!]*$/i, (msg) ->
    name    = msg.match[1].trim()
    newRole = msg.match[2].trim()
    console.log("blah", name, newRole)

    unless name in ['', 'who', 'what', 'where', 'when', 'why']
      unless newRole.match(/^not\s+/i)
        users = usersForMentionName(name)
        if users.length is 1
          user = users[0]
          user.roles = user.roles or [ ]

          if newRole in user.roles
            msg.send "I know"
          else
            user.roles.push(newRole)
            console.log("before 1", name, robot.name, robot.mention_name)
            if name.toLowerCase() is robot.name.toLowerCase() or
            name.toLowerCase() is robot.mention_name.toLowerCase()
              msg.send "Ok, I am #{newRole}."
            else
              msg.send "Ok, @#{user.mention_name} is #{newRole}."
        else if users.length > 1
          msg.send getAmbiguousUserText users
        else
          msg.send "I don't know anything about #{name}."

  robot.respond /@?([\w .-_]+) is not (["'\w -_]+)[.!]*$/i, (msg) ->
    name    = msg.match[1].trim()
    newRole = msg.match[2].trim()

    unless name in ['', 'who', 'what', 'where', 'when', 'why']
      users = usersForMentionName(name)
      if users.length is 1
        user = users[0]
        user.roles = user.roles or [ ]

        if newRole not in user.roles
          msg.send "I know."
        else
          user.roles = (role for role in user.roles when role isnt newRole)
          msg.send "Ok, @#{user.mention_name} is no longer #{newRole}."
      else if users.length > 1
        msg.send getAmbiguousUserText users
      else
        msg.send "I don't know anything about #{name}."

