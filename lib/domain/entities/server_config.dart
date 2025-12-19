class ServerConfig {
  final String id;
  final String name;
  final String host;
  final int port;
  final String username;
  final String password;

  ServerConfig({
    required this.id,
    required this.name,
    required this.host,
    required this.port,
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'host': host,
    'port': port,
    'username': username,
    'password': password,
  };

  factory ServerConfig.fromJson(Map<String, dynamic> json) => ServerConfig(
    id: json['id'],
    name: json['name'],
    host: json['host'],
    port: json['port'],
    username: json['username'],
    password: json['password'],
  );
}
