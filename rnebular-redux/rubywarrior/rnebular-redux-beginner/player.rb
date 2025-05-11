class Player
  @health
  @rescued

  def damage_check(warrior)
    if @health_now < @health
      return true
    else
      return false
    end
  end
  
  def start_turn(warrior)
    # set first round values
    @health = warrior.health if @health.nil?
    @rescued = 0 if @rescued.nil?
    @rest = false if @rest.nil?
    @end_of_turn = false if @end_of_turn.nil?

    # get health and report stuff
    @health_now=warrior.health
    puts " * Starting the turn with #{@health_now} HP's."
    puts " * Health at the end of last round was #{@health} HP's."
    puts " * Rescued: #{@rescued}"
  end

  def look_around(warrior)
    @look_forward=warrior.look(:forward)
    @look_backward=warrior.look(:backward)
    puts " * Look forward: #{@look_forward[0]}, #{@look_forward[1]}, #{@look_forward[2]}"
    puts " * Look backward: #{@look_backward[0]}, #{@look_backward[1]}, #{@look_backward[2]}"
  end

  def health_check(warrior)
    # check if my health is below 15
    puts "Health currently #{@health_now}, do I need to rest? y/n"
    answer = gets.chomp
    if answer == "y"
      puts "Resting."
      warrior.rest!
      @end_of_turn = true
    else
      puts "Not resting."
    end
  end

  def retreat_check(warrior)
    puts "Should I retreat or pivot?"
    answer = gets.chomp
    if answer == "retreat"
      puts "Retreating."
      warrior.walk!(:backward)
      @end_of_turn = true
    elsif answer == "pivot"
      puts "Turning around."
      warrior.pivot!(:backward)
      @end_of_turn = true
    else
      puts "Not retreating or pivoting."
    end
  end

  def find_target(warrior,target,direction)
    if direction == :forward
      @look_direction = @look_forward
    elsif direction == :backward
      @look_direction = @look_backward
    end

    puts "Looking for #{target} in direction #{direction}."
    # check for archer in range, if found attack unless its behind a Captive
    if @look_direction[2] == target
      puts "#{target} in range, making sure no captive is in the way."
      if @look_direction[0-1].captive?
        puts "#{target} not a threat, is behind a captive."
        return false
      elsif @look_direction[0-1].enemy?
        # enemy in the way, need to attack
        puts "#{target} in range, but another enemy in the way."
        return false
      else
        puts "#{target} in range, clear shot."
        return true
      end
    elsif @look_direction[1] == target
      puts "#{target} in range, making sure no captive is in the way."
      if @look_direction[0].captive?
        puts "#{target} not a threat yet, is behind a captive."
        return false
      elsif @look_direction[0].enemy?
        # enemy in the way, need to attack
        puts "#{target} in range, but enemy in the way."
        return false
      else
        puts "#{target} in range, clear shot."
        return true
      end
    elsif @look_direction[0] == target
      puts "#{target} in range, clear shot."
      return true
    else
      # no target in range to shoot in this direction
      puts "#{target} not in range: #{direction}."
      return false
    end
  end
  
  def move_forward(warrior)
    if @look_forward[0].wall?
      puts "Wall in front, turning around."
      warrior.pivot!(:backward)
      @end_of_turn = true
    else
      puts "Walking forward."
      warrior.walk!(:forward)
      @end_of_turn = true
    end
  end

  def play_turn(warrior)
    # stuff to do at the start of every turn
    start_turn(warrior)
    look_around(warrior)

    while @end_of_turn == false
      # stuff that should make this level work
      
      # report my health and see if I should rest
      health_check(warrior)

      # check to see if I should retreat
      retreat_check(warrior)

      # assume it's safe to attack or rescue
      puts "Checking to see if an archer is in range to hit me."
      if find_target(warrior,'Archer',:forward) == true
        puts "Archer in shooting range forward, shooting!"
        warrior.shoot!(:forward)
        @end_of_turn = true
      elsif find_target(warrior,'Archer',:backward) == true
        puts "Archer in shooting range behind me, shooting behind!"
        warrior.shoot!(:backward)
        @end_of_turn = true
      elsif find_target(warrior,'Wizard',:forward) == true
        puts "Wizard in shooting range forward, shooting!"
        warrior.shoot!(:forward)
        @end_of_turn = true
      elsif find_target(warrior,'Wizard',:backward) == true
        puts "Wizard in shooting range behind me, shooting behind!"
        warrior.shoot!(:backward)
        @end_of_turn = true
      elsif warrior.feel(:forward).enemy?
        puts "Enemy in range, attacking!"
        warrior.attack!(:forward)
        @end_of_turn = true
      elsif warrior.feel(:forward).captive?
        puts "Captive in front of me, rescuing!"
        warrior.rescue!(:forward)
        @rescued += 1
        @end_of_turn = true
      elsif warrior.feel(:backward).enemy?
        puts "Enemy in range, attacking!"
        warrior.attack!(:backward)
        @end_of_turn = true
      elsif warrior.feel(:backward).captive?
        puts "Captive in front of me, rescuing!"
        warrior.rescue!(:backward)
        @rescued += 1
        @end_of_turn = true
      else
        # move forward until we hit a wall, then
        # turn around and move forward until we go up the stairs
        move_forward(warrior)
      end
    end
  end
end