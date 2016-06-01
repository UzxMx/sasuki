# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# application = Application.new({
#   app_id: '57813bc1-2b0a-4b16-ba6a-d1bcbd49facc',
#   name: 'Kumamoto',
#   app_type: Application.app_types['android']
# })
# application.save!

device = Device.find(1)
device.info = '{}'
device.save!