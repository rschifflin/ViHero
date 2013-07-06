require "curses"
require "#{File.dirname(__FILE__)}/position"
require "#{File.dirname(__FILE__)}/instructor"
include Curses

def start_curses
  screen = init_screen
  cbreak
  start_color
  curs_set 0
  noecho
  Curses::timeout = 0 

  init_pair(1, COLOR_GREEN, COLOR_BLACK)
  init_pair(2, COLOR_YELLOW, COLOR_BLACK)
  init_pair(3, COLOR_RED, COLOR_BLACK)
end

def end_curses
  nocbreak
  echo
  close_screen
end

def each_frame(frames_per_sec = 60.0)
  start_time = Time.now 
  frames_per_sec = 1.0 if frames_per_sec <= 0
  secs_per_frame = 1.0/frames_per_sec
  yield secs_per_frame
  
  elapsed = Time.now - start_time
  sleep([secs_per_frame - elapsed, 0].max)
end

def erase(target = :all)
  case target
  when :all then
    #Clear every line and column
    lines.times do |y|
      setpos(y,0)
      cols.times do
        addch(' ')
      end
    end

  when :pre then
    #Clear only the splats
    (2..4).each { |i| setpos(i,0); addch(' ') }
    (7..9).each { |i| setpos(i,0); addch(' ') }

  when :main then
    #Clear the center line and bottom 3 lines
    setpos(lines/2,0)
    cols.times { addch(' ') }
   
    (1..3).each do |i|
      setpos(lines-i, 0)
      cols.times { addch(' ') }
    end
  end
end

def pre_loop
  game_data = {new: false, live: true, difficulty: :normal, length: 30}
  
  setpos(0,0)
  addstr("  VI HERO -- LEARNING TO NAVIGATE WITH H,J,K,L\n")
  addstr("Choose a difficulty:\n")
  attron(color_pair(1)) { addstr(" [E]asy\n")   }
  attron(color_pair(2)) { addstr(" [N]ormal\n") }
  attron(color_pair(3)) { addstr(" [H]ard\n")   }

  addstr("\nChoose a duration:\n")
  attron(color_pair(1)) { addstr(" [S]hort - 10 commands\n")   }
  attron(color_pair(2)) { addstr(" [M]edium - 30 commands\n") }
  attron(color_pair(3)) { addstr(" [L]ong - 99 commands\n")   }
  addstr("\nPress ENTER to begin!")

  splats = [3, 8]
  setpos(splats[0],0)
  addch('*')
  
  setpos(splats[1],0)
  addch('*')

  acceptset = %w[e E n N h H s S m M l L]
  while (input = getch) != 10 #ENTER key
    if (acceptset.include? input)
      erase(:pre)
      case input
      when 'e'||'E' then splats[0] = 2; game_data[:difficulty] = :easy
      when 'n'||'N' then splats[0] = 3; game_data[:difficulty] = :normal
      when 'h'||'H' then splats[0] = 4; game_data[:difficulty] = :hard

      when 's'||'S' then splats[1] = 7; game_data[:length] = 10 
      when 'm'||'M' then splats[1] = 8; game_data[:length] = 30 
      when 'l'||'L' then splats[1] = 9; game_data[:length] = 99 
      end

      setpos(splats[0], 0)
      addch('*')
      setpos(splats[1], 0)
      addch('*')
      refresh
    end
  end

  game_data
end

def main_loop game_data
  instructor = Instructor.new(game_data[:difficulty])
  while instructor.scorecard.scores.size < game_data[:length]
    each_frame(60.0) do |t| #60 FPS
      input = getch
      return if input == 'q'
      instructor.send_char(input)
      instructor.generate_instruction if instructor.free?
      instructor.draw
      instructor.tick t
      
      setpos(lines-3, (cols/2) - 9)
      addstr("To go: #{game_data[:length] - instructor.scorecard.scores.size}")
      refresh
      erase(:main)
    end
  end

  result_string = "Press Enter to view your results"
  l = result_string.length
  setpos( (lines/2), (cols/2) - (l/2))
  addstr(result_string)
  instructor.scorecard.draw
  refresh

  input = getch until input == 10

  game_data[:scores] = instructor.scorecard.scores
  game_data
end

def post_loop game_data
  total = game_data[:length] 
  hit   = game_data[:scores].count{|s| true if s[:mark]=='O'}
  late  = game_data[:scores].count{|s| true if s[:mark]=='X'}
  total == 0 ? hitper = 100 : hitper = (hit*100 / total)
  
  htotal = game_data[:scores].count{|s| true if s[:goal]=='<'}
  jtotal = game_data[:scores].count{|s| true if s[:goal]=='v'}
  ktotal = game_data[:scores].count{|s| true if s[:goal]=='^'}
  ltotal = game_data[:scores].count{|s| true if s[:goal]=='>'}

  hhit = game_data[:scores].count{|s| true if s[:mark]=='O' && s[:goal]=='<'}
  jhit = game_data[:scores].count{|s| true if s[:mark]=='O' && s[:goal]=='v'}
  khit = game_data[:scores].count{|s| true if s[:mark]=='O' && s[:goal]=='^'}
  lhit = game_data[:scores].count{|s| true if s[:mark]=='O' && s[:goal]=='>'}

  htotal == 0 ? hper = 100 : hper = (hhit*100 / htotal)
  jtotal == 0 ? jper = 100 : jper = (jhit*100 / jtotal)
  ktotal == 0 ? kper = 100 : kper = (khit*100 / ktotal)
  ltotal == 0 ? lper = 100 : lper = (lhit*100 / ltotal)

  green  = game_data[:scores].count{|s| true if s[:colorid] == 1}
  yellow = game_data[:scores].count{|s| true if s[:colorid] == 2}
  red    = game_data[:scores].count{|s| true if s[:colorid] == 3 && s[:mark] == 'O'}
  speed  = green*3 + yellow*2 + red*1
  hit == 0 ? speedper = 100 : speedper = ((speed*100) / (hit*3))
  final = (hitper + speedper) / 2

  setpos(1,0)
  addstr("\tYour results:\n")
  addstr("\t\tDifficulty: #{game_data[:difficulty].to_s.capitalize}\n")
  addstr("\t\tDuration: #{game_data[:length]} commands\n")
  addstr("\t\t\tAccuracy:\t#{hit} / #{total}\t(#{hitper}%)\n")
  attron(color_pair(1)){ addstr("\t\t\t\tLefts:\t#{hhit} / #{htotal}\t(#{hper}%)\n") } 
  attron(color_pair(1)){ addstr("\t\t\t\tDowns:\t#{jhit} / #{jtotal}\t(#{jper}%)\n") } 
  attron(color_pair(1)){ addstr("\t\t\t\tUps:\t#{khit} / #{ktotal}\t(#{kper}%)\n") } 
  attron(color_pair(1)){ addstr("\t\t\t\tRights:\t#{lhit} / #{ltotal}\t(#{lper}%)\n") } 
  
  addstr("\n\t\t\tSpeed:\t\t#{speed} / #{hit*3}\t(#{speedper}%)\n") 
  attron(color_pair(1)){ addstr("\t\t\t\tPerfect:\t#{green}\n") } 
  attron(color_pair(2)){ addstr("\t\t\t\tOK:\t\t#{yellow}\n") } 
  attron(color_pair(3)){ addstr("\t\t\t\tSlow:\t\t#{red}\n") } 
  attron(color_pair(3)){ addstr("\t\t\t\tLate:\t\t#{late}\n") }

  addstr("\nFINAL SCORE: #{final}%\n")
  addstr("[N]ew settings | [R]etry | [Q]uit")
  acceptset = %w[n N r R q Q]
  
  new_game_data = {new: false, live: false}
  (input = getch) until acceptset.include?(input)
  case input
  when 'n'||'N' then
    new_game_data[:new] = true
    new_game_data[:live] = true
  when 'r'||'R' then
    new_game_data[:live] = true
    new_game_data[:difficulty] = game_data[:difficulty]
    new_game_data[:length] = game_data[:length]
  end

  return new_game_data
end

start_curses
game_data = {new: true, live: true}
while game_data[:live]
  erase(:all)
  game_data = pre_loop if game_data[:new]
  erase(:all)
  game_data = main_loop(game_data)
  erase(:all)
  game_data = post_loop(game_data)
end
end_curses
