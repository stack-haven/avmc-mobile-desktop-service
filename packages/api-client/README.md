# @avmc/api-client

跨端共享 API 客户端。由 `backend-service/proto` 自动生成。

## 生成方式

```bash
./tool/gen_clients.sh
```

## 使用

### Flutter（Dart）

```dart
import 'package:api_client/evie/v1/dictionary.pbgrpc.dart';

final client = DictionaryServiceClient(channel);
final response = await client.listWords(...);
```

### React Native / uni-app（TypeScript）

```typescript
import { DictionaryServiceClient } from '@avmc/api-client/proto/evie/v1/dictionary_pb_service';
import { ListWordsRequest } from '@avmc/api-client/proto/evie/v1/dictionary_pb';

const client = new DictionaryServiceClient('https://api.avmc.example.com');
const response = await client.listWords(new ListWordsRequest());
```

## ⚠️ 不要手动修改

本目录由 `tool/gen_clients.sh` 自动生成。手动修改会在下次生成时被覆盖。
