class Node
  attr_reader :type
  attr_accessor :neighbors, :distance, :room, :area, :type

  def initialize(data)
    @room, @area, @type = data[:room], data[:area], data[:type]
  end

  def measure_distance(areas, rooms)
    rooms_range = rooms[:max] - rooms[:min]
    areas_range = areas[:max] - areas[:min]

    neighbors.each do |node|
      delta_rooms = (node.room - room) / rooms_range
      delta_areas = (node.area - area) / areas_range

      node.distance = Math.sqrt(delta_rooms * delta_rooms + delta_areas * delta_areas)
    end
  end

  def sort_by_distance
    neighbors.sort! { |a, b| a.distance - b.distance }
  end

  def guess_type(k)
    types = {}

    neighbors[0..k].each do |neighbor|
      if types[neighbor.type].nil?
        types[neighbor.type] = 0
      end
      types[neighbor.type] += 1
    end

    guess = { type: false, count: 0 }

    types.each do |type, count|
      if count > guess.count
        guess[:type] = type
        guess[:count] = count
      end
    end
    p "Area: #{area}"
    p "Rooms: #{room}"
    "Guessing #{guess[:type]}"
  end
end

class NodeList
  attr_reader :k, :nodes, :areas, :rooms

  def initialize(k)
    @nodes = []
    @k = k
    @areas = { min: 1_000_000, max: 0 }
    @rooms = { min: 1_000_000, max: 0 }
  end

  def add(node)
    nodes << node
  end

  def unknown
    calculate_ranges

    nodes.each do |node|
      if !node.type
        node.neighbors = []
        nodes.each do |neighbor_node|
          next if !neighbor_node.type
          node.neighbors << Node.new(room: neighbor_node.room, area: neighbor_node.area, type: neighbor_node.type)
        end

        node.measure_distance(areas, rooms)
        node.sort_by_distance
        puts node.guess_type(k)
      end
    end
  end

  def calculate_ranges
    nodes.each do |node|
      rooms[:min] = node.room if node.room < rooms[:min]
      areas[:min] = node.area if node.area < areas[:min]
      rooms[:max] = node.room if node.room > rooms[:max]
      areas[:max] = node.area if node.area > areas[:max]
    end
  end
end

data = [
  {room: 1, area: 350, type: 'apartment'},
  {room: 2, area: 300, type: 'apartment'},
  {room: 3, area: 300, type: 'apartment'},
  {room: 4, area: 250, type: 'apartment'},
  {room: 4, area: 500, type: 'apartment'},
  {room: 4, area: 400, type: 'apartment'},
  {room: 5, area: 450, type: 'apartment'},

  {room: 7,  area: 850,  type: 'house'},
  {room: 7,  area: 900,  type: 'house'},
  {room: 7,  area: 1200, type: 'house'},
  {room: 8,  area: 1500, type: 'house'},
  {room: 9,  area: 1300, type: 'house'},
  {room: 8,  area: 1240, type: 'house'},
  {room: 10, area: 1700, type: 'house'},
  {room: 9,  area: 1000, type: 'house'},

  {room: 1, area: 800,  type: 'flat'},
  {room: 3, area: 900,  type: 'flat'},
  {room: 2, area: 700,  type: 'flat'},
  {room: 1, area: 900,  type: 'flat'},
  {room: 2, area: 1150, type: 'flat'},
  {room: 1, area: 1000, type: 'flat'},
  {room: 2, area: 1200, type: 'flat'},
  {room: 1, area: 1300, type: 'flat'},
]

nodes = NodeList.new(3)
data.each do |data|
  nodes.add(Node.new(data))
end

random_room = (rand * 10).round(1)
random_area = (rand * 2_000).round(1)

nodes.add(Node.new(room: random_room, area: random_area, type: nil))
nodes.unknown
