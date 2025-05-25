// lib/services/appwrite_client.dart

import 'package:appwrite/appwrite.dart';

final client = Client()
  .setEndpoint('https://fra.cloud.appwrite.io/v1')
  .setProject('682ed1b4000f293ec42e');

final databases = Databases(client);
