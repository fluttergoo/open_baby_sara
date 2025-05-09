import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomizeGrowthCard extends StatefulWidget {
  final Color color;
  final String title;
  final String babyID;
  final String firstName;
  final String imgUrl;
  final VoidCallback voidCallback;
  const CustomizeGrowthCard({super.key,required this.color,
    required this.title,
    required this.babyID,
    required this.firstName, required this.imgUrl, required this.voidCallback,});

  @override
  State<CustomizeGrowthCard> createState() => _CustomizeGrowthCardState();
}

class _CustomizeGrowthCardState extends State<CustomizeGrowthCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: widget.color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: SizedBox(
        height: 110.h,
        child: Stack(
          children: [
            /// Title
            Positioned(
              top: 10.h,
              left: 45.w,
              child: Row(
                children: [
                  Column(
                    children: [
                      Text(
                        'Weight',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                        ),
                      ),
                      Text(
                        '29 lb',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'May 8,2025',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 10.w,),
                  Column(
                    children: [
                      Text(
                        'Height',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                        ),
                      ),
                      Text(
                        '39 inch',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,

                        ),
                      ),
                      Text(
                        'May 8,2025',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 10.w,),
                  Column(
                    children: [
                      Text(
                        'Head Size',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                        ),
                      ),
                      Text(
                        '25 inch',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,

                        ),
                      ),
                      Text(
                        'May 8,2025',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),


                ],
              ),
            ),

            /// Add new activity icon
            Positioned(
              top: 4.h,
              right: 6.w,
              child: CircleAvatar(
                radius: 16.r,
                backgroundColor: Theme.of(context).primaryColor,
                child: IconButton(
                  onPressed: widget.voidCallback,
                  icon: Icon(Icons.add, color: Colors.white, size: 20.sp),
                ),
              ),
            ),

            // Sol alt icon (asset image)
            Positioned(
              bottom: 10.h,
              top: 10.h,
              left: 2.w,
              child: Image.asset(
                widget.imgUrl,
                height: 45.h,
                width: 45.w,
                fit: BoxFit.contain,
              ),
            ),


          ],
        ),
      ),
    );
  }
}
