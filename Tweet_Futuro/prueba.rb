class Person

  attr_reader :name

  def initialize(name)
    @name = name
    p "soy una persona"
  end

  def self.otra
    "lala"
  end

  def saluda
    "Hola mi nombre es " + @name
  end

  def hola
    p self
  end

end

persona = Person.new("Diana")

p persona.saluda

p Person.otra

persona.hola