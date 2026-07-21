# Paw — API Summary for Flutter

Backend base URL: `http://localhost:3000` (dev) / `https://your-api.com` (prod)

Every route below (except `/health`) is mounted under the `/user` prefix —
e.g. `POST /user/bookings`, not `POST /bookings`.

All endpoints marked **Bearer** require:
```
Authorization: Bearer <jwt_token>
```

### Error shape (all endpoints)
```json
{ "error": "Human-readable message", "details": ["optional", "validation", "errors"] }
```
Status codes: `400` bad input · `401` unauthenticated · `403` forbidden · `404` not found · `409` conflict · `422` unprocessable · `500` server error

---

## 1. Auth — `/user/auth`

| Method | Endpoint | Auth | Body → Response |
|--------|----------|------|------------------|
| POST | `/user/auth/register` | — | `{ full_name, email, password }` → `{ token, user }` |
| POST | `/user/auth/login` | — | `{ email, password }` → `{ token, user }` |
| GET | `/user/auth/google` | — | Redirects to Google OAuth consent screen |
| GET | `/user/auth/callback` | — | OAuth callback; redirects to `FRONTEND_URL` with `?token=` |
| GET | `/user/auth/me` | Bearer | → `{ user }` |

`user` object: `{ user_id, email, full_name, role, picture, actor_sheet_id, auth_provider, status }`

```dart
class UserModel {
  final String userId;
  final String email;
  final String fullName;
  final String role;
  final String? picture;
  final String? actorSheetId;

  const UserModel({
    required this.userId,
    required this.email,
    required this.fullName,
    required this.role,
    this.picture,
    this.actorSheetId,
  });

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
        userId:       j['user_id'] as String,
        email:        j['email'] as String,
        fullName:     j['full_name'] as String,
        role:         j['role'] as String,
        picture:      j['picture'] as String?,
        actorSheetId: j['actor_sheet_id'] as String?,
      );
}
```

---

## 2. Services — `/user/services`

| Method | Endpoint | Auth | Body → Response |
|--------|----------|------|------------------|
| GET | `/user/services` | — | → `{ services: ServiceModel[] }` (active only, sorted by `sort_order`) |
| GET | `/user/services/:id` | — | → `{ service }` |

```dart
class ServiceModel {
  final String serviceId;
  final String name;
  final String description;
  final double priceFrom;
  final String icon;     // key into the app's local icon map
  final String color;    // card background hex, e.g. "#D6EAE4"
  final String category;

  const ServiceModel({
    required this.serviceId,
    required this.name,
    required this.description,
    required this.priceFrom,
    required this.icon,
    required this.color,
    required this.category,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> j) => ServiceModel(
        serviceId:   j['service_id'] as String,
        name:        j['name'] as String,
        description: j['description'] as String? ?? '',
        priceFrom:   (j['price_from'] as num).toDouble(),
        icon:        j['icon'] as String,
        color:       j['color'] as String,
        category:    j['category'] as String,
      );
}
```

---

## 3. Profile — `/user/profile`

| Method | Endpoint | Auth | Body → Response |
|--------|----------|------|------------------|
| GET | `/user/profile` | Bearer | → `{ profile }` (auto-created on first call) |
| PATCH | `/user/profile` | Bearer | `{ full_name?, phone?, avatar_url?, bio? }` → `{ profile }` |

`profile` object: `{ user_id, full_name, email, phone, avatar_url, bio, role, auth_provider, status }`

---

## 4. Bookings — `/user/bookings`

This is the API behind the **New Booking** screen (pet name, pet type, stay
duration, daily rate, notes → Confirm Booking). `service_id` is carried over
from whichever service card the user tapped to get here — it is not a field
on the form itself.

| Method | Endpoint | Auth | Body → Response |
|--------|----------|------|------------------|
| POST | `/user/bookings` | Bearer | Create booking → `{ booking }` |
| GET | `/user/bookings` | Bearer | `?status=&limit=&offset=` → `{ bookings, total, limit, offset }` |
| GET | `/user/bookings/active` | Bearer | Confirmed + active bookings (Stays tab) → `{ bookings, total }` |
| GET | `/user/bookings/:id` | Bearer | → `{ booking }` |
| PATCH | `/user/bookings/:id` | Bearer | `{ notes?, status? }` → `{ booking }` |

### Create — request body
```json
{
  "pet_name":   "Buddy",
  "pet_type":   "dog",
  "service_id": "svc_bath_grm",
  "start_date": "2026-06-12",
  "end_date":   "2026-06-16",
  "daily_rate": 25,
  "notes":      "Loves belly rubs"
}
```
- `pet_type` must be one of: `dog`, `cat`, `bird`, `rabbit`, `other`
- `service_id` must reference an existing service (404 if not found)
- `end_date` must be strictly after `start_date` (400 otherwise)
- `notes` is optional

### Booking object (response)
```json
{
  "booking_id":   "bk_sjK8C8N7qc",
  "pet_name":     "Buddy",
  "pet_type":     "dog",
  "service_id":   "svc_bath_grm",
  "service_name": "Bath & Grooming",
  "start_date":   "2026-06-12",
  "end_date":     "2026-06-16",
  "daily_rate":   25,
  "notes":        "Loves belly rubs",
  "status":       "pending",
  "nights":       4,
  "total":        100
}
```
`nights` and `total` (`daily_rate * nights`) are computed server-side on every read — use them directly for the confirmation/receipt screen, no client-side math needed.

`status` lifecycle: `pending → confirmed → active → completed`, or `→ cancelled` at any point before `completed`.

### Update
- Regular users may only PATCH `notes` and/or set `status: "cancelled"`. Any other status value returns `400`.
- A booking already `cancelled` or `completed` can no longer be modified (`409`).
- (Moving a booking through `confirmed` / `active` / `completed` is an admin-side operation, not yet exposed on a user-facing route.)

```dart
class BookingModel {
  final String bookingId;
  final String petName;
  final String petType;
  final String serviceId;
  final String serviceName;
  final DateTime startDate;
  final DateTime endDate;
  final double dailyRate;
  final String notes;
  final String status;
  final int nights;
  final double total;

  const BookingModel({
    required this.bookingId,
    required this.petName,
    required this.petType,
    required this.serviceId,
    required this.serviceName,
    required this.startDate,
    required this.endDate,
    required this.dailyRate,
    required this.notes,
    required this.status,
    required this.nights,
    required this.total,
  });

  factory BookingModel.fromJson(Map<String, dynamic> j) => BookingModel(
        bookingId:   j['booking_id'] as String,
        petName:     j['pet_name'] as String,
        petType:     j['pet_type'] as String,
        serviceId:   j['service_id'] as String,
        serviceName: j['service_name'] as String,
        startDate:   DateTime.parse(j['start_date'] as String),
        endDate:     DateTime.parse(j['end_date'] as String),
        dailyRate:   (j['daily_rate'] as num).toDouble(),
        notes:       j['notes'] as String? ?? '',
        status:      j['status'] as String,
        nights:      j['nights'] as int,
        total:       (j['total'] as num).toDouble(),
      );
}
```

```dart
class BookingsRepository {
  Future<BookingModel> create({
    required String petName,
    required String petType,
    required String serviceId,
    required DateTime startDate,
    required DateTime endDate,
    required double dailyRate,
    String? notes,
  }) async {
    final res = await apiClient.post('/user/bookings', data: {
      'pet_name':   petName,
      'pet_type':   petType,
      'service_id': serviceId,
      'start_date': startDate.toIso8601String().split('T').first,
      'end_date':   endDate.toIso8601String().split('T').first,
      'daily_rate': dailyRate,
      if (notes != null) 'notes': notes,
    });
    return BookingModel.fromJson(res.data['booking'] as Map<String, dynamic>);
  }

  Future<List<BookingModel>> list({String? status}) async {
    final res = await apiClient.get('/user/bookings', params: {
      if (status != null) 'status': status,
    });
    final list = res.data['bookings'] as List<dynamic>;
    return list.map((j) => BookingModel.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<List<BookingModel>> listActive() async {
    final res = await apiClient.get('/user/bookings/active');
    final list = res.data['bookings'] as List<dynamic>;
    return list.map((j) => BookingModel.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<BookingModel> cancel(String bookingId) async {
    final res = await apiClient.patch('/user/bookings/$bookingId', data: {
      'status': 'cancelled',
    });
    return BookingModel.fromJson(res.data['booking'] as Map<String, dynamic>);
  }
}
```

---

## 5. Catalog Items — `/user/shops/:id/catalog-items` & `/user/catalog-items`

Shop catalogs hold both bookable `service` items and purchasable `product`
items.

| Method | Endpoint | Auth | Body → Response |
|--------|----------|------|------------------|
| GET | `/user/shops/:id/catalog-items` | — | Items for one shop → `{ items: CatalogItemModel[] }` |
| GET | `/user/catalog-items` | — | Cross-shop items (e.g. home-screen "Featured Products") → `{ items: CatalogItemModel[] }` |

`/user/catalog-items` query params (all optional):
- `type` — `service` or `product`
- `limit` — positive int, caps the number of items returned

`catalog item` object: `{ item_id, shop_id, item_type, name, description, price_from, icon, color, image, category, active, sort_order }`

`image` is a URL string and may be empty (`""`) — render with a themed
fallback (icon + tinted background) rather than leaving a blank space when
empty or when the network image fails to load.

```dart
abstract final class CatalogItemType {
  static const service = 'service';
  static const product = 'product';
}

class CatalogItemModel {
  final String itemId;
  final String shopId;
  final String itemType;
  final String name;
  final String description;
  final double priceFrom;
  final String icon;     // key into the app's local icon map
  final String color;    // card background hex, e.g. "#D6EAE4"
  final String image;    // product/service photo URL, may be ""
  final String category;

  const CatalogItemModel({
    required this.itemId,
    required this.shopId,
    required this.itemType,
    required this.name,
    required this.description,
    required this.priceFrom,
    required this.icon,
    required this.color,
    this.image = '',
    required this.category,
  });

  factory CatalogItemModel.fromJson(Map<String, dynamic> j) => CatalogItemModel(
        itemId:      j['item_id'] as String,
        shopId:      j['shop_id'] as String,
        itemType:    j['item_type'] as String? ?? CatalogItemType.service,
        name:        j['name'] as String,
        description: j['description'] as String? ?? '',
        priceFrom:   (j['price_from'] as num).toDouble(),
        icon:        j['icon'] as String? ?? '',
        color:       j['color'] as String? ?? '#E8F0EE',
        image:       j['image'] as String? ?? '',
        category:    j['category'] as String? ?? '',
      );
}
```

```dart
class CatalogRepository {
  // Shop-scoped (e.g. shop detail screen)
  Future<List<CatalogItemModel>> getCatalogItems(String shopId) async {
    final res = await apiClient.get('/user/shops/$shopId/catalog-items');
    final list = res.data['items'] as List<dynamic>;
    return list.map((j) => CatalogItemModel.fromJson(j as Map<String, dynamic>)).toList();
  }

  // Cross-shop (e.g. home-screen "Featured Products")
  Future<List<CatalogItemModel>> getFeaturedItems({String? type, int? limit}) async {
    final res = await apiClient.get('/user/catalog-items', params: {
      if (type != null) 'type': type,
      if (limit != null) 'limit': limit,
    });
    final list = res.data['items'] as List<dynamic>;
    return list.map((j) => CatalogItemModel.fromJson(j as Map<String, dynamic>)).toList();
  }
}
```

---

## 6. Commands quick reference

```bash
# Seed services into the admin sheet (run once)
pnpm db:seed seeds/admin.ts --skip-existing

# Seed 3 test user accounts (jamie / taylor / morgan @test.local, password Test1234!)
pnpm db:seed seeds/test-users.ts --skip-existing

# Start the API server
pnpm dev
```
