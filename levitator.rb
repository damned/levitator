
class Tick
  def self.next
    if @next.nil?
      @next = 0
    end
    next_tick = Tick.new(@next)
    @next += 1
    next_tick
  end
  def initialize(seconds)
    @seconds = seconds
  end
  def every?(seconds)
    (@seconds % seconds) == 0
  end
end

class Transition
  def initialize(next_state, duration_s)
  end
end

class Strategy
  def distribute(visitors, elevators)
    elevators.each {|lift|
      lift.enter visitors.take(lift.space)
    }
  end
end

class Elevator
  def initialize
    @floor = Floors.origin
    @state = :open
    @capacity = 9
    @passengers = []
  end
  def open_at?(floor)
    at?(floor) && state?(:open)
  end
  def enter(entrants)
    @passengers += entrants
    raise "you are kidding me: trying to fit #{@passengers.size} into a #{@capacity} capacity lift!" if @passengers.size > @capacity
  end
  def space
    @capacity - @passengers.size
  end
  def to_s
    "passengers: #{@passengers.size}, #{@state} at floor #{@floor}"
  end
  private
  def state?(state)
    @state == state
  end
  def at?(floor)
    @floor == floor
  end
end

class Levitator
  def initialize(strategy)
    @strategy = strategy
  end
  def handle(traffic)
    elevators = [Elevator.new]
    visitors = []
    until traffic.done?
      tick = Tick.next
      visitors += traffic.visitors(tick)
      loadable = elevators.select {|lift|
        lift.open_at?(Floors.origin)
      }
      @strategy.distribute(visitors, loadable)
      puts "visitors: #{visitors.count} elevators: #{elevators.map(&:to_s).join ', '}"
    end
  end
end

class Visitor
  def initialize(destination)
    @destination = destination
  end
end

class Floors
  AllDestinations = %w(16 17 18 19 20 21 22 23 24 25 26 27)
  @next_index = 0
  def self.next_destination
    destination = AllDestinations[@next_index]
    @next_index = (@next_index + 1) % AllDestinations.size
    destination
  end
  def self.origin
    "0"
  end
  def self.seconds_taken(from, to)
    8 + distance(from, to) * 2
  end
  private
  def self.distance(from, to)
    (from.to_i - to.to_i).abs
  end
end

class Traffic
  SecondsPerVisitor = 60 / 12 # assume constant 12/m
  def initialize
    @destinations = Floors
    @to_come = 100
  end
  def visitors(tick)
    if tick.every?(SecondsPerVisitor)
      @to_come -=1
      return [new_visitor]
    end
    []
  end
  def done?
    @to_come <= 0
  end
  private
  def new_visitor
    Visitor.new(@destinations.next_destination)
  end
end

levitator = Levitator.new(Strategy.new)
levitator.handle(Traffic.new)
