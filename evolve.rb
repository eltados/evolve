class World
  attr_accessor :options, :creatures, :generation

  def initialize(options={})
    @options ={}
    @creatures =[]
    @generation =0


    default = {:creatures=>20}
    default.each_pair do |key, val|
      @options[key] =  options[key]||val
    end

    @options[:creatures].times do
      @creatures << Creature.generate
    end

  end

  def new_generation
    @generation +=1
    children = []

    couples = select_couples
    couples.each do |couple|
      children << couple[0].mate(couple[1])
    end
    @creatures = children.flatten

  end

  def select_couples
    couples= []
    parents = @creatures.sort {|x,y| y.fitness <=> x.fitness }
    males = parents.slice(0,(parents.size/2))
    females = parents.slice(0,(parents.size/2)).sort_by { rand }
    (@creatures.size/2).times do |i|
          couples << [males[i],females[i]]
    end

    return couples

  end

  def fitness
      recompute_fitness
  end

  def avg_fitness
    fitness/creatures.size.to_f
  end

  def recompute_fitness
    sum = 0
    @creatures.each do | creature|
      sum += creature.fitness.to_i
    end
    return sum
  end

  def to_s
    "generation{gen=>#{@generation},fit=>#{fitness},avg_fit=>#{avg_fitness}} \n\t"+@creatures.join(",")
  end

end

class Creature
  attr_accessor :genes, :complexity

  def initialize(options=nil)
    if options.nil?
      @genes =[]
      @complexity = 10
    else
      @genes = options[:genes]
      @complexity = @genes.size
      if(rand(100)<2)
        @genes[rand(@genes.size)].mutate
      end
    end
  end

  def self.generate
    me = self.new
    me.complexity.times do
      me.genes << Gene.generate
    end
    return me
  end

  def to_s
    "<#{@genes.join}>{#{fitness}}"
  end

  def mate(c2)
    c1 = self
    split_point = rand(complexity)+1

    genes1 = []
    genes1  << c1.genes[0..split_point-1]
    genes1  << c2.genes[split_point..c2.genes.size]
    genes1.flatten!

    genes2 = []
    genes2  << c2.genes[0..split_point-1]
    genes2  << c1.genes[split_point..c1.genes.size]
    genes2.flatten!

    return [Creature.new(:genes=>genes2), Creature.new(:genes=>genes1)]
  end

  def fitness
    @genes.inject do |sum, n|
      sum.to_i + n.to_i
    end
  end

end

class Gene
  attr_accessor :value

  def initialize
    @value =nil
  end

  def self.generate
    me = self.new
    me.value = rand(10)
    return me
  end

  def to_s
    @value.to_s
  end

  def to_i
    @value.to_i
  end

  def mutate
    @value = Gene.generate.value
  end

end
#
#5.times do
#  c = Creature.generate
#  puts c
#end
#
#5.times do
#  g = Gene.generate
#  puts g
#  g.mutate
#  puts g
#end



w = World.new(:creatures=> 32)
32.times do
  puts w.to_s
  w.new_generation
end
