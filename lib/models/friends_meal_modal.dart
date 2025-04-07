class FriendsMealModal {
  String avatar; // User's profile picture
  String mealImage; // Food/dish photo
  String userName; // User's display name
  int calories; // Numeric value for calculations
  String timeAgo; // Formatted time display (e.g., "2h ago")

  FriendsMealModal({
    required this.avatar,
    required this.mealImage,
    required this.userName,
    required this.calories,
    required this.timeAgo,
  });

  static List<FriendsMealModal> getFriendsMeal() {
    List<FriendsMealModal> friendsMeal = [];

    friendsMeal.add(
      FriendsMealModal(
        avatar: "assets/img/avatar.jpeg",
        mealImage: "assets/img/meal.jpg",
        userName: "Steve",
        calories: 4000,
        timeAgo: "1h",
      ),
    );
    friendsMeal.add(
      FriendsMealModal(
        avatar: "assets/img/avatar.jpeg",
        mealImage: "assets/img/meal.jpg",
        userName: "Robert Downey Jr",
        calories: 2500,
        timeAgo: "2h",
      ),
    );
    friendsMeal.add(
      FriendsMealModal(
        avatar: "assets/img/avatar.jpeg",
        mealImage: "assets/img/meal.jpg",
        userName: "Scarlett Johansson",
        calories: 1000,
        timeAgo: "1min",
      ),
    );
    friendsMeal.add(
      FriendsMealModal(
        avatar: "assets/img/avatar.jpeg",
        mealImage: "assets/img/meal.jpg",
        userName: "Chris Hemsworth",
        calories: 3090,
        timeAgo: "20min",
      ),
    );
    friendsMeal.add(
      FriendsMealModal(
        avatar: "assets/img/avatar.jpeg",
        mealImage: "assets/img/meal.jpg",
        userName: "Tom Holland",
        calories: 2500,
        timeAgo: "10h",
      ),
    );
    friendsMeal.add(
      FriendsMealModal(
        avatar: "assets/img/avatar.jpeg",
        mealImage: "assets/img/meal.jpg",
        userName: "elizabeth olsen",
        calories: 2000,
        timeAgo: "8h",
      ),
    );
    friendsMeal.add(
      FriendsMealModal(
        avatar: "assets/img/avatar.jpeg",
        mealImage: "assets/img/meal.jpg",
        userName: "Chris Evans",
        calories: 4000,
        timeAgo: "23h",
      ),
    );
    friendsMeal.add(
      FriendsMealModal(
        avatar: "assets/img/avatar.jpeg",
        mealImage: "assets/img/meal.jpg",
        userName: "Jason Statham",
        calories: 3000,
        timeAgo: "5min",
      ),
    );
    friendsMeal.add(
      FriendsMealModal(
        avatar: "assets/img/avatar.jpeg",
        mealImage: "assets/img/meal.jpg",
        userName: "Jason Statham",
        calories: 3100,
        timeAgo: "5min",
      ),
    );
    friendsMeal.add(
      FriendsMealModal(
        avatar: "assets/img/avatar.jpeg",
        mealImage: "assets/img/meal.jpg",
        userName: "Jason Statham",
        calories: 100,
        timeAgo: "5min",
      ),
    );
    friendsMeal.add(
      FriendsMealModal(
        avatar: "assets/img/avatar.jpeg",
        mealImage: "assets/img/meal.jpg",
        userName: "Jason Statham",
        calories: 3023,
        timeAgo: "5min",
      ),
    );
    friendsMeal.add(
      FriendsMealModal(
        avatar: "assets/img/avatar.jpeg",
        mealImage: "assets/img/meal.jpg",
        userName: "Jason Statham",
        calories: 4310,
        timeAgo: "5min",
      ),
    );
    friendsMeal.add(
      FriendsMealModal(
        avatar: "assets/img/avatar.jpeg",
        mealImage: "assets/img/meal.jpg",
        userName: "Jason Statham",
        calories: 3102,
        timeAgo: "5min",
      ),
    );
    friendsMeal.add(
      FriendsMealModal(
        avatar: "assets/img/avatar.jpeg",
        mealImage: "assets/img/meal.jpg",
        userName: "Jason Statham",
        calories: 2000,
        timeAgo: "5min",
      ),
    );
    return friendsMeal;
  }
}
