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
        calories: 123,
        timeAgo: "1h",
      ),
    );
    friendsMeal.add(
      FriendsMealModal(
        avatar: "assets/img/avatar.jpeg",
        mealImage: "assets/img/meal.jpg",
        userName: "Robert Downey Jr",
        calories: 123,
        timeAgo: "2h",
      ),
    );
    friendsMeal.add(
      FriendsMealModal(
        avatar: "assets/img/avatar.jpeg",
        mealImage: "assets/img/meal.jpg",
        userName: "Scarlett Johansson",
        calories: 123,
        timeAgo: "1min",
      ),
    );
    friendsMeal.add(
      FriendsMealModal(
        avatar: "assets/img/avatar.jpeg",
        mealImage: "assets/img/meal.jpg",
        userName: "Chris Hemsworth",
        calories: 123,
        timeAgo: "20min",
      ),
    );
    friendsMeal.add(
      FriendsMealModal(
        avatar: "assets/img/avatar.jpeg",
        mealImage: "assets/img/meal.jpg",
        userName: "Tom Holland",
        calories: 123,
        timeAgo: "10h",
      ),
    );
    friendsMeal.add(
      FriendsMealModal(
        avatar: "assets/img/avatar.jpeg",
        mealImage: "assets/img/meal.jpg",
        userName: "elizabeth olsen",
        calories: 123,
        timeAgo: "8h",
      ),
    );
    friendsMeal.add(
      FriendsMealModal(
        avatar: "assets/img/avatar.jpeg",
        mealImage: "assets/img/meal.jpg",
        userName: "Chris Evans",
        calories: 123,
        timeAgo: "23h",
      ),
    );
    friendsMeal.add(
      FriendsMealModal(
        avatar: "assets/img/avatar.jpeg",
        mealImage: "assets/img/meal.jpg",
        userName: "Jason Statham",
        calories: 123,
        timeAgo: "5min",
      ),
    );
    return friendsMeal;
  }
}
