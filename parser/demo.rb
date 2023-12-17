require_relative 'main_application'

username = 'simple_login1712'
password = 'password1712'
data_path = './out'

app = MainApplication.new(username, password, data_path)
app.run