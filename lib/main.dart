import 'package:flutter/material.dart';

void main() {
  runApp(const FoodDeliveryApp());
}

class FoodDeliveryApp extends StatelessWidget {
  const FoodDeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Food Delivery App',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: Colors.white,
        cardTheme: const CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class FoodItem {
  final String id;
  final String name;
  final String category;
  final int price;
  final IconData icon;
  final String restaurant;
  final String description;

  const FoodItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.icon,
    required this.restaurant,
    required this.description,
  });
}

class RestaurantInfo {
  final String name;
  final String tag;
  final String delivery;
  final Color color;

  const RestaurantInfo({
    required this.name,
    required this.tag,
    required this.delivery,
    required this.color,
  });
}

class OrderInfo {
  final String id;
  final String title;
  final String status;
  final int total;
  final DateTime date;

  const OrderInfo({
    required this.id,
    required this.title,
    required this.status,
    required this.total,
    required this.date,
  });
}

class CartEntry {
  final FoodItem food;
  int quantity;

  CartEntry({required this.food, this.quantity = 1});
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isLoggedIn = false;
  String _userName = 'Guest';
  String _userEmail = '';
  String _deliveryAddress = '';
  String _paymentMethod = 'M-Pesa';
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<FoodItem> _foods = const [
    FoodItem(
      id: 'pizza_margherita',
      name: 'Margherita Pizza',
      category: 'Pizza',
      price: 1200,
      icon: Icons.local_pizza,
      restaurant: 'Sunset Pizzeria',
      description: 'Classic tomato, mozzarella and basil with extra cheese.',
    ),
    FoodItem(
      id: 'pepperoni',
      name: 'Pepperoni Pizza',
      category: 'Pizza',
      price: 1450,
      icon: Icons.local_pizza,
      restaurant: 'Urban Slice',
      description: 'Spicy pepperoni, crispy crust and fresh herbs.',
    ),
    FoodItem(
      id: 'beef_burger',
      name: 'Beef Burger',
      category: 'Burgers',
      price: 950,
      icon: Icons.lunch_dining,
      restaurant: 'Burger Barn',
      description: 'Juicy beef patty, cheddar, lettuce and signature sauce.',
    ),
    FoodItem(
      id: 'chicken_burger',
      name: 'Crispy Chicken Burger',
      category: 'Burgers',
      price: 900,
      icon: Icons.lunch_dining,
      restaurant: 'Burger Barn',
      description: 'Golden chicken fillet, coleslaw and spicy mayo.',
    ),
    FoodItem(
      id: 'mango_smoothie',
      name: 'Mango Smoothie',
      category: 'Drinks',
      price: 450,
      icon: Icons.local_drink,
      restaurant: 'Fresh Bar',
      description: 'Sweet mango blended with yogurt and ice.',
    ),
    FoodItem(
      id: 'iced_coffee',
      name: 'Iced Coffee',
      category: 'Drinks',
      price: 380,
      icon: Icons.local_cafe,
      restaurant: 'Bean & Brew',
      description: 'Cold brew coffee with milk and caramel.',
    ),
  ];

  final List<RestaurantInfo> _restaurants = const [
    RestaurantInfo(
      name: 'Sunset Pizzeria',
      tag: 'Pizza specialist',
      delivery: '15-25 min',
      color: Color(0xFFFFA726),
    ),
    RestaurantInfo(
      name: 'Burger Barn',
      tag: 'Best burgers in town',
      delivery: '10-20 min',
      color: Color(0xFF66BB6A),
    ),
    RestaurantInfo(
      name: 'Fresh Bar',
      tag: 'Healthy drinks',
      delivery: '8-15 min',
      color: Color(0xFF42A5F5),
    ),
    RestaurantInfo(
      name: 'Bean & Brew',
      tag: 'Coffee and snacks',
      delivery: '12-18 min',
      color: Color(0xFFAB47BC),
    ),
  ];

  final List<OrderInfo> _orders = [
    OrderInfo(
      id: 'ORD-2301',
      title: 'Pizza & Mango Smoothie',
      status: 'Delivered',
      total: 1650,
      date: DateTime(2026, 5, 22),
    ),
    OrderInfo(
      id: 'ORD-2302',
      title: 'Beef Burger Meal',
      status: 'On the way',
      total: 1150,
      date: DateTime(2026, 5, 28),
    ),
  ];

  final List<CartEntry> _cart = [];
  final Set<String> _favoriteIds = {};

  int get _cartCount => _cart.fold(0, (count, entry) => count + entry.quantity);
  int get _cartTotal => _cart.fold(0, (total, entry) => total + entry.food.price * entry.quantity);

  List<FoodItem> get _filteredFoods {
    final query = _searchQuery.trim().toLowerCase();
    return _foods.where((food) {
      final matchesSearch = query.isEmpty || food.name.toLowerCase().contains(query) || food.restaurant.toLowerCase().contains(query);
      final matchesCategory = _selectedCategory == 'All' || food.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  void _addToCart(FoodItem food) {
    final existing = _cart.where((entry) => entry.food.id == food.id).toList();
    setState(() {
      if (existing.isNotEmpty) {
        existing.first.quantity++;
      } else {
        _cart.add(CartEntry(food: food));
      }
    });
  }

  void _removeFromCart(CartEntry entry) {
    setState(() {
      if (entry.quantity > 1) {
        entry.quantity--;
      } else {
        _cart.remove(entry);
      }
    });
  }

  void _toggleFavorite(FoodItem food) {
    setState(() {
      if (_favoriteIds.contains(food.id)) {
        _favoriteIds.remove(food.id);
      } else {
        _favoriteIds.add(food.id);
      }
    });
  }

  void _openAuthDialog() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: _userName == 'Guest' ? '' : _userName);
    final emailController = TextEditingController(text: _userEmail);
    final passwordController = TextEditingController();
    bool registerMode = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Text(registerMode ? 'Register' : 'Login'),
            content: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (registerMode)
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (value) => value == null || value.isEmpty ? 'Name is required' : null,
                    ),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => value == null || !value.contains('@') ? 'Enter a valid email' : null,
                  ),
                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (value) => value == null || value.length < 6 ? '6+ characters required' : null,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setDialogState(() {
                    registerMode = !registerMode;
                  });
                },
                child: Text(registerMode ? 'Have an account?' : 'Create account'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState?.validate() ?? false) {
                    setState(() {
                      _isLoggedIn = true;
                      _userName = registerMode ? nameController.text.trim() : emailController.text.split('@').first;
                      _userEmail = emailController.text.trim();
                    });
                    Navigator.pop(context);
                  }
                },
                child: Text(registerMode ? 'Register' : 'Login'),
              ),
            ],
          );
        });
      },
    );
  }

  void _showCheckoutPopup() {
    final address = _deliveryAddress.trim().isEmpty ? 'No address entered' : _deliveryAddress.trim();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Checkout Summary'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Items: $_cartCount'),
              const SizedBox(height: 6),
              Text('Total: KES $_cartTotal'),
              const SizedBox(height: 6),
              Text('Address: $address'),
              const SizedBox(height: 6),
              Text('Payment: $_paymentMethod'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_cart.isEmpty) return;
                setState(() {
                  _cart.clear();
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Order placed! Delivery is on the way.'),
                ));
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: TextField(
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search food, restaurants or categories',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.orange.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    final categories = ['All', 'Pizza', 'Burgers', 'Drinks'];
    return SizedBox(
      height: 50,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = categories[index];
          final selected = _selectedCategory == category;
          return ChoiceChip(
            label: Text(category),
            selected: selected,
            selectedColor: Colors.orange.shade400,
            backgroundColor: Colors.orange.shade50,
            labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87),
            onSelected: (_) => setState(() => _selectedCategory = category),
          );
        },
      ),
    );
  }

  Widget _buildRestaurantCards() {
    return SizedBox(
      height: 170,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        scrollDirection: Axis.horizontal,
        itemCount: _restaurants.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final restaurant = _restaurants[index];
          return Container(
            width: 220,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                colors: [restaurant.color, restaurant.color.withOpacity(0.85)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.restaurant_menu, color: Colors.white, size: 28),
                const SizedBox(height: 20),
                Text(
                  restaurant.name,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 6),
                Text(restaurant.tag, style: const TextStyle(color: Colors.white70)),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.delivery_dining, color: Colors.white70, size: 18),
                    const SizedBox(width: 6),
                    Text(restaurant.delivery, style: const TextStyle(color: Colors.white70)),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFoodItems(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final crossAxisCount = width > 900 ? 3 : width > 600 ? 2 : 1;
      return GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _filteredFoods.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 1.75,
        ),
        itemBuilder: (context, index) {
          final food = _filteredFoods[index];
          final isFavorite = _favoriteIds.contains(food.id);
          return Container(
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.orange.shade100,
                        child: Icon(food.icon, color: Colors.deepOrange, size: 24),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.red : Colors.black54),
                        onPressed: () => _toggleFavorite(food),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(food.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(food.description, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                  const Spacer(),
                  Row(
                    children: [
                      Text('KES ${food.price}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const Spacer(),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        onPressed: () => _addToCart(food),
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildSectionHeader(String title, [String? subtitle]) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade700)),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchField(),
          _buildCategoryChips(),
          _buildSectionHeader('Restaurant Listings', 'Browse popular nearby kitchens'),
          _buildRestaurantCards(),
          _buildSectionHeader('Popular Dishes'),
          _buildFoodItems(context),
          _buildSectionHeader('Features You Can Add Later'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: const [
                Chip(label: Text('Push Notifications')),
                Chip(label: Text('Real-time order tracking')),
                Chip(label: Text('Saved payment cards')),
                Chip(label: Text('Live restaurant reviews')),
                Chip(label: Text('Loyalty rewards')),
              ],
            ),
          ),
          const SizedBox(height: 18),
        ],
      ),
    );
  }

  Widget _buildCartTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        children: [
          if (_cart.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.orange.shade200),
                    const SizedBox(height: 18),
                    const Text('Your cart is empty', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Add food from the home screen to start your order.', textAlign: TextAlign.center),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: _cart.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final entry = _cart[index];
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: Colors.orange.shade100,
                            child: Icon(entry.food.icon, color: Colors.deepOrange, size: 26),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(entry.food.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 6),
                                Text('KES ${entry.food.price} x ${entry.quantity}', style: const TextStyle(color: Colors.black54)),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: () => _removeFromCart(entry),
                              ),
                              Text('${entry.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () => setState(() => entry.quantity++),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 12),
          TextField(
            onChanged: (value) => setState(() => _deliveryAddress = value),
            decoration: InputDecoration(
              labelText: 'Delivery Address',
              hintText: 'Enter delivery location',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Payment method', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildPaymentChoice('M-Pesa'),
                    const SizedBox(width: 8),
                    _buildPaymentChoice('Cash'),
                    const SizedBox(width: 8),
                    _buildPaymentChoice('Card'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total', style: TextStyle(color: Colors.black54)),
                    const SizedBox(height: 4),
                    Text('KES $_cartTotal', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                onPressed: _cart.isEmpty ? null : _showCheckoutPopup,
                child: const Text('Checkout'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersTab() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        final order = _orders[index];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.history, color: Colors.deepOrange),
                    const SizedBox(width: 10),
                    Text(order.id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: order.status == 'Delivered' ? Colors.green.shade100 : Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(order.status, style: TextStyle(color: order.status == 'Delivered' ? Colors.green.shade700 : Colors.orange.shade700)),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(order.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                Text('KES ${order.total}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text('Date: ${order.date.day}/${order.date.month}/${order.date.year}', style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFavoritesTab() {
    final favoriteFoods = _foods.where((food) => _favoriteIds.contains(food.id)).toList();
    if (favoriteFoods.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_border, size: 70, color: Colors.orange.shade200),
            const SizedBox(height: 16),
            const Text('No favorites yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text('Tap the heart icon on a dish to save it here.'),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      itemCount: favoriteFoods.length,
      itemBuilder: (context, index) {
        final food = favoriteFoods[index];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange.shade100,
              child: Icon(food.icon, color: Colors.deepOrange),
            ),
            title: Text(food.name),
            subtitle: Text(food.restaurant),
            trailing: Text('KES ${food.price}'),
          ),
        );
      },
    );
  }

  Widget _buildProfileTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: ListView(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: Colors.deepOrange.shade100,
                  child: Text(
                    _userName.isEmpty ? 'G' : _userName[0].toUpperCase(),
                    style: const TextStyle(fontSize: 28, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_userName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(_isLoggedIn ? _userEmail : 'Guest user', style: const TextStyle(color: Colors.black54)),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  onPressed: _openAuthDialog,
                  child: Text(_isLoggedIn ? 'Manage' : 'Login'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Account Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: ListTile(
              leading: const Icon(Icons.location_on, color: Colors.deepOrange),
              title: const Text('Delivery Address'),
              subtitle: Text(_deliveryAddress.isEmpty ? 'Add your preferred address in Cart' : _deliveryAddress),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: ListTile(
              leading: const Icon(Icons.payment, color: Colors.deepOrange),
              title: const Text('Payment Methods'),
              subtitle: Text(_paymentMethod),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: ListTile(
              leading: const Icon(Icons.star_border, color: Colors.deepOrange),
              title: const Text('Rate the App'),
              subtitle: const Text('Help us improve with feedback'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 24),
          const Text('Account Tips', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.orange.shade50,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('• Save your favorite restaurants'),
                SizedBox(height: 8),
                Text('• Use M-Pesa for fast checkout'),
                SizedBox(height: 8),
                Text('• Track orders and view history'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentChoice(String title) {
    final selected = _paymentMethod == title;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _paymentMethod = title),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? Colors.deepOrange : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selected ? Colors.deepOrange : Colors.grey.shade300),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(color: selected ? Colors.white : Colors.black87, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titles = ['Home', 'Cart', 'Orders', 'Favorites', 'Profile'];
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_currentIndex]),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () => setState(() => _currentIndex = 1),
                  ),
                  if (_cartCount > 0)
                    Positioned(
                      top: 8,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        child: Text('$_cartCount', style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeTab(),
          _buildCartTab(),
          _buildOrdersTab(),
          _buildFavoritesTab(),
          _buildProfileTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.black54,
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart),
                if (_cartCount > 0)
                  Positioned(
                    right: 0,
                    child: CircleAvatar(
                      radius: 7,
                      backgroundColor: Colors.red,
                      child: Text('$_cartCount', style: const TextStyle(fontSize: 10, color: Colors.white)),
                    ),
                  ),
              ],
            ),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Orders'),
          const BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
