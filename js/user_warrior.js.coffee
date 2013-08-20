class UserWarrior extends Base
  white_list = [
    "attack", "interact", "dart",
    "rest",   "walk",     "feel",
    "look",   "left",     "right",
    "up",     "down"
  ]

  constructor: (warrior)->
    return if !warrior
    white_list.forEach (field)=>
      @[field] = -> warrior[field].apply(warrior, arguments)

    @getter "health", -> warrior.health

jQuery.extend window,
  UserWarrior: UserWarrior