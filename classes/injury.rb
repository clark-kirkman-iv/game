class Injury
  MAX_DURATION = 100
  SEVERITY = {
    'uninjured' => {:low => 0,  :high => 0},
    'minor'     => {:low => 1,  :high => 10},
    'hampered'  => {:low => 11, :high => 50},
    'disabled'  => {:low => 50, :high => MAX_DURATION},
  }
  
  attr_reader :duration
  
  def initialize(duration)
    duration = MAX_DURATION if duration > MAX_DURATION # ck4, for now, allow up to this amount only
    duration = 0 if duration < 0
    @duration = duration
  end
  
  def severity
    raise "undefined"
    sev = SEVERITY.select{ |severity|
      severity.fetch(:low) <= @duration && @duration <= severity.fetch(:high)
    }
    raise "SEVERITY hash is set up inappropriately." if sev.keys.length != 1
    return sev.keys.first
  end
  
  def forward_time
    @duration -= 1 if @duration > 0
  end
  
  def injure(duration)
    @duration += duration
    @duration = MAX_DURATION if @duration > MAX_DURATION
  end
  
end
