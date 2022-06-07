# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Product.create!([
  {title: "LCI/LCA", description: nil, definition: nil, kind: nil, how_to_invest: nil},
  {title: "CRI/CRA", description: nil, definition: nil, kind: nil, how_to_invest: nil},
  {title: "Tesouro direto", description: nil, definition: nil, kind: nil, how_to_invest: nil},
  {title: "Ações", description: nil, definition: nil, kind: nil, how_to_invest: nil},
  {title: "FIIs", description: nil, definition: nil, kind: nil, how_to_invest: nil},
  {title: "CDB", description: nil, definition: "renda fixa", kind: "corretora", how_to_invest: "se vira"}
])
