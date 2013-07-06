
class Scorecard
  attr_reader :scores

  def initialize
    @mark_map = {left: '<', down: 'v', up: '^', right: '>'}
    @mark_map.default = 'X'
    
    @scores = Array.new
  end

  def add_hit(direction, colorid)
    goal = @mark_map[direction]
    mark = 'O'
    @scores << {goal: goal, mark: mark, colorid: colorid}
    flash
  end

  def add_miss(targetdir, missdir)
    goal = @mark_map[targetdir]
    mark = @mark_map[missdir]
    @scores << {goal: goal, mark: mark, colorid: 3}
    beep
  end

  def draw
    if @scores.count > cols
      draw_scores = @scores.slice(-cols..-1)
    else
      draw_scores = @scores
    end

    setpos(lines - 2, 0)
    draw_scores.each do |s|
      attron(color_pair(1)){ addch(s[:goal]) }
    end
    
    setpos(lines - 1, 0)
    draw_scores.each do |s|
      attron(color_pair(s[:colorid])){ addch(s[:mark]) }
    end
  end

  def clear
    @scores = Array.new
  end
end

class Instructor
  attr_reader :instruction, :scorecard

  def initialize(difficulty)
    @warmup = true
    @countdown = 3
    
    case difficulty
    when :easy then @ttl = 5
    when :normal then @ttl = 3
    when :hard then @ttl = 1
    else @ttl = 3
    end
    @scorecard = Scorecard.new
  end

  def generate_instruction
    @warmup = false if @countdown == 0
    
    if @warmup
      @instruction = Instruction.new(@countdown.to_s, 1)
      @instruction.move_to(cols/2, lines/2)
      @countdown -= 1
      return
    end

    case Random.rand(4)
      when 0 then direction = :up
      when 1 then direction = :down
      when 2 then direction = :left
      when 3 then direction = :right
    end

    @instruction = Instruction.new(direction, @ttl)
    @instruction.move_to(cols/2, lines/2)
  end

  def draw
    @instruction.draw if @instruction
    @scorecard.draw
  end

  def tick(t = 1.0/60.0)
    if @instruction

      if @instruction.expired?
        @scorecard.add_miss(@instruction.dir, :x) if @warmup == false
        @instruction = nil
      else 
        @instruction.tick t
      end

    end
  end

  def free?
    @instruction.nil?
  end

  def send_char char
    return if @warmup

    input_map = {
      'h' => :left, 
      'j' => :down, 
      'k' => :up,
      'l' => :right
    }

    if @instruction && @instruction.dir == input_map[char]
      @scorecard.add_hit(@instruction.dir, @instruction.colorid)
      @instruction = nil
    elsif @instruction && input_map[char]
      @scorecard.add_miss(@instruction.dir, input_map[char])
      @instruction = nil
    end
  end

end

class Instruction
  attr_reader :dir, :colorid

  def initialize(direction, ttl=3.0)
    @dir = direction
    @pos = Position.new
    @ttl_secs_max = ttl
    @ttl_secs = @ttl_secs_max
    @colorid = 1
  end

  def expired?
    @ttl_secs <= 0
  end

  def draw
    green_range = @ttl_secs_max*0.666..@ttl_secs_max
    yellow_range = @ttl_secs_max*0.333...@ttl_secs_max*0.666
    red_range = 0...@ttl_secs_max*0.333
    case @ttl_secs
      when green_range then @colorid = 1
      when yellow_range then @colorid = 2
      else @colorid = 3
    end
 
    setpos(*@pos.yx)
    attron(color_pair(@colorid)) { addstr(@dir.to_s) }
  end

  def move_to(x, y)
    @pos.x = x
    @pos.y = y
  end

  def tick(t = 1.0/60.0)
    @ttl_secs -= t if @ttl_secs > 0
    @pos.x = (cols/2.0) * (@ttl_secs.to_f / @ttl_secs_max)
  end
end


