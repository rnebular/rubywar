class Player
  @health
  @end_of_turn
  @direction

  def being_attacked(warrior)
    if (warrior.health >= @health)
      @health=warrior.health
      return false
    else
      @health=warrior.health
      return true
    end
  end

  def check_behind(warrior)
    # puts "#{warrior.look(:backward)[0]}"
    # puts "#{warrior.look(:backward)[1]}"
    # puts "#{warrior.look(:backward)[2]}"
    for space in warrior.look(:backward)
      if space(:backward).captive? and !@end_of_turn
        check_captive_backward(warrior)
        @end_of_turn = true
      else
        if space(:backward).enemy? and !@end_of_turn
          puts "Bad guy backward, shooting!"
          warrior.shoot!(:backward)
          @end_of_turn = true
        else
          puts "no bad guys or captives found backward."
      end
    end
  end

  def check_forward(warrior)
    # puts "#{warrior.look[0]}"
    # puts "#{warrior.look[1]}"
    # puts "#{warrior.look[2]}"
    for space in warrior.look
      if space.captive? and !@end_of_turn
        check_captive(warrior)
        @end_of_turn = true
      else
        if space.enemy? and !@end_of_turn
          puts "Bad guy forward, shooting!"
          warrior.shoot!
          @end_of_turn = true
        else
          puts "no bad guys or captives found."
      end
    end
  end

  def backup_rest(warrior)
    if warrior.feel(:backward).empty?
      warrior.walk!(:backward)
    else
      if warrior.health < 20
        puts "resting."
        warrior.rest!
        @end_of_turn = true
      else
        puts "We are back to full health, attacking!"
        @rest = false
        attack(warrior)
      end
    end
  end

  def check_captive_backward(warrior)
    if warrior.look(:backward)[0].captive? and !@end_of_turn
      puts "captive found backward, rescuing!"
      warrior.rescue!(:backward)
      @end_of_turn = true
    else
      if warrior.look(:backward)[0].wall? and !@end_of_turn
        puts "wall behind, walking forward."
        warrior.walk!
        @end_of_turn = true
      else
        for space in warrior.look(:backward)
          if space.captive?

  end

  def check_captive(warrior)
    if warrior.look[0].captive? and !@end_of_turn
      puts "captive found, rescuing!"
      warrior.rescue!
      @end_of_turn=true
    else
      if warrior.look[0].wall? and !@end_of_turn
        puts "facing the end wall, pivoting."
        warrior.pivot!
        @end_of_turn = true
      else
        puts "empty in front, moving forward."
        if warrior.look[0].empty? and !@end_of_turn
          warrior.walk!
          @end_of_turn = true
        else
          puts "not sure what to do now, will ponder."
          @end_of_turn = true
        end
      end
    end
  end

  def play_turn(warrior)
    # Turn code always goes here
    @health = warrior.health if @health.nil?
    puts "Starting the turn with #{warrior.health} HP's."
    @end_of_turn=false
    if @rest.nil?
      @rest = false
      puts "First turn, looking around."
      check_behind(warrior)
      check_forward(warrior)
      check_captive(warrior)
      @end_of_turn = true
    else
      puts "Rest = #{@rest}"
      if @rest == false
        if warrior.health<10
          puts "health below 10, resting."
          @rest = true
          backup_rest(warrior)
        else
          puts "We don't need rest, looking around."
          check_behind(warrior)
          check_forward(warrior)
          if @end_of_turn == false
            check_captive(warrior)
          else
            puts "turn over."
          end
        end
      else
        if warrior.health<20
          backup_rest(warrior)
        else
          check_captive(warrior)
        end
      end
    end

    @health = warrior.health
  end
end
