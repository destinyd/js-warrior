class Action extends Base
  constructor: ->
    @type = @class_name()

  steps: ->

  perform: ->
    return @fail() if @is_fail()
    if @actor
      @actor.direction = @direction if @direction
      @actor.level.add_action(@)
    if @target_space
      @target = @target_space.character
      !@target && @target = @target_space.item
    @steps()

  is_dart: ->
    @class_name() == "dart"
    
  is_fail: ->
    false

  fail: ->
    @failed = true
    @actor.idle(@actor, @) if @actor
      
class Idle extends Action
  constructor: (@actor, @action)->
    @direction = @action.direction if @action
    super()

class Walk extends Action
  constructor: (@actor, @direction)->
    super()
    @target_space = @actor.space.get_relative_space(direction, 1)

  is_fail: ->
    !@target_space.can_walk()

  steps: ->
    @actor.update_link(@target_space)

class Rest extends Action
  constructor: (@actor, @hp_change)->
    super()

  steps: ->
    @actor.health_delta(@hp_change)

class Attack extends Action
  constructor: (@actor, @direction, @distance)->
    super()
    @hp_change    = -@actor.damage
    @target_space = @actor.space.get_relative_space(@direction, distance)
  
  is_fail: ->
    @target_space.units().some((u)=> !u.destroyable)

  steps: ->
    @target.take_attack(@) if @target

class Interact extends Action
  constructor: (@actor, @direction)->
    super()
    @target_space = @actor.space.get_relative_space(@direction, 1)
    @item         = @target_space.item
    @lock         = @target_space.lock

  is_fail: ->
    !(@item && @item.can_interact(@actor))

  steps: ->
    @actor.direction = @direction
    @item.take_interact(@) if @item

class Excited extends Action
  constructor: (@actor)->
    super()

  steps: ->
    @actor.excited = true

class Explode extends Action
  constructor: (@actor)->
    super()
    @hp_change = -10000
    @targets = @actor.get_attack_area()
      .filter((s)=> s.has_blowupable())
      .map((s)=> s.units())
      .reduce((a, b)=> a.concat b)

  steps: ->
    @targets.forEach (u)=> u.take_explode(@)

class Shot extends Attack
class Magic extends Attack
class Dart extends Attack
  constructor: (@actor, @direction, @distance)->
    super(arguments...)
    @hp_change = -@actor.shuriken_damage

  is_fail: ->
    !@actor.has_shuriken()

  steps: ->
    @shuriken.update_link(@target_space) if !@target
    @target && !@target.space.has('wall') && @target.take_dart(@)


jQuery.extend window,
  Rest:       Rest
  Walk:       Walk
  Interact:   Interact
  Attack:     Attack
  Shot:       Shot
  Magic:      Magic
  Excited:    Excited
  Explode:    Explode
  Dart:       Dart
  Idle:       Idle
