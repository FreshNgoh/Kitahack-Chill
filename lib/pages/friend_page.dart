import 'package:flutter/material.dart';
import 'package:flutter_application/models/friends_meal_modal.dart';

class FriendPage extends StatelessWidget {
  FriendPage({super.key});

  final List<FriendsMealModal> friendsMeal = FriendsMealModal.getFriendsMeal();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          SizedBox(height: 30),
          _goal(),
          SizedBox(height: 40),
          _friendList(),
          SizedBox(height: 40),
        ],
      ),
    );
  }

  Padding _goal() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "Goal with ",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20, // Original size
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: "Steve",
                  style: TextStyle(
                    color: Color(0xff179C52),
                    fontSize: 28, // Bigger size for Steve
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Text(
            '123 CAL',
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w600,
              color: Color(0xff176BEF),
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              // Funtion here
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: Size.zero, // Remove default minimum size
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min, // Makes row take minimum space
              children: [
                Icon(Icons.add_circle_outline, color: Colors.black, size: 20),
                SizedBox(width: 8),
                Text(
                  'Add Goal',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Column _friendList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
          child: Text(
            "What's your friend eating?",
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: friendsMeal.length,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          separatorBuilder: (context, index) => const SizedBox(height: 25),
          itemBuilder: (context, index) {
            final list = friendsMeal[index];
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: AssetImage(list.avatar),
                ),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    spacing: 6,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        spacing: 10,
                        children: [
                          Text(
                            list.userName,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            list.timeAgo,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${list.calories} CAL',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xff176BEF),
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          list.mealImage,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
