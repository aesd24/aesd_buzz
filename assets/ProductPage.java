// ignore_for_file: deprecated_member_use

import 'dart:js_util';

import 'package:buzz/Widgets/comuntitle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../Widgets/sizebox.dart';
import '../appstaticdata/staticdata.dart';
import '../comunbottombar.dart';
import '../provider/proviercolors.dart';
import '../staticdata.dart';
import 'newhover.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({Key? key}) : super(key: key);

  @override
  State<ProductPage> createState() => _ProductPageState();
}

List<String> dropdownOptions1 = ['Featured', 'Lowest Price', 'Highest Price'];
String? selectedOption1 = "Featured";




int counter = 0;


List category =[
  "All",
  "Man",
  "Woman",
  "Kids",
  "Underwear",
  "Tops",
  "All",
  "Man",
  "Woman",
  "Kids",
  "Underwear",
  "Tops",
];

int selectCategory = 0;

final AppConst controller = Get.put(AppConst());

class _ProductPageState extends State<ProductPage> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppConst>(builder: (controller) {
      return Consumer<ColorNotifire>(
        builder: (context, value, child) {
          return Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: notifire!.getbgcolor,
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                if (constraints.maxWidth < 600) {
                  controller.gridcounter.value = 1;

                  // Mobile layout
                  return SizedBox(
                    height: 900,
                    width: double.infinity,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        children: [
                          const ComunTitle(
                              title: 'Product', path: "E-Commerce"),
                          const SizedBox(
                            height: padding,
                          ),
                          _buildLayoutSelectionmobile(),
                          _buildsearchbar(size: constraints.maxWidth),
                          SizedBox(
                            height: MediaQuery.of(context).size.height,
                            child: _buildgridview(width: constraints.maxWidth),
                          ),
                          const SizeBoxx(),
                          const ComunBottomBar()
                        ],
                      ),
                    ),
                  );
                } else if (constraints.maxWidth < 1200) {
                  if (constraints.minWidth < 800) {
                    controller.gridcounter.value = 2;

                    return SizedBox(
                      height: 1000,
                      width: double.infinity,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const ComunTitle(
                                title: 'Product', path: "E-Commerce"),
                            const SizedBox(
                              height: padding,
                            ),
                            _builddropdown(),
                            _buildsearchbar(size: constraints.maxWidth),
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: MediaQuery.of(context).size.height,
                                    child: _buildgridview(
                                        width: constraints.maxWidth),
                                  ),
                                ),
                              ],
                            ),
                            _buildcart(),
                            const SizeBoxx(),
                            const ComunBottomBar()
                          ],
                        ),
                      ),
                    );
                  } else {
                    controller.gridcounter.value = 3;

                    return SizedBox(
                      height: 1000,
                      width: double.infinity,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const ComunTitle(
                                title: 'Product', path: "E-Commerce"),
                            const SizedBox(
                              height: padding,
                            ),
                            Row(
                              children: [
                                Expanded(
                                    flex: 3,
                                    child: _buildcategory(maxWidth: constraints.maxWidth)),
                                 Expanded(
                                    flex: 1,
                                    child: _buildcart()),
                              ],
                            ),
                            const SizeBoxx(),
                            const ComunBottomBar()
                          ],
                        ),
                      ),
                    );
                  }
                  // Tablet layout
                } else {
                  controller.gridcounter.value = 4;
                  // Website layout
                  return SizedBox(
                    // height: 1000,
                    width: double.infinity,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const ComunTitle(
                              title: 'Product', path: "E-Commerce"),
                          const SizedBox(
                            height: padding,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                   flex: 3,
                                  child: _buildcategory(maxWidth: constraints.maxWidth)),
                               Expanded(
                                  flex: 1,
                                  child: _buildcart()),
                            ],
                          ),
                          const SizeBoxx(),
                          const ComunBottomBar(),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          );
        },
      );
    });
  }

Widget _buildcart(){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 15),
      child: Container(
        // height: 800,
        width: 200,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
              Radius.circular(12)),
          color: notifire!.getcontiner,
          boxShadow: boxShadow,
        ),
        child: Padding(
          padding: const EdgeInsets.all(padding),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Shopping Cart",style: mainTextStyle.copyWith(color: notifire!.getMainText),),
                const SizedBox(height: 15,),
                TextField(
                  decoration: InputDecoration(
                    hintText: "Customer Name",
                    hintStyle: mediumGreyTextStyle,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),borderSide: BorderSide(color: Colors.grey.withOpacity(0.3))),
                    disabledBorder:  OutlineInputBorder(borderRadius: BorderRadius.circular(12),borderSide: BorderSide(color: Colors.grey.withOpacity(0.3))),
                    enabledBorder:  OutlineInputBorder(borderRadius: BorderRadius.circular(12),borderSide: BorderSide(color: Colors.grey.withOpacity(0.3))),
                  ),
                ),
                const SizedBox(height: 15,),
                Row(
                  children: [
                    SvgPicture.asset("assets/shopping-cart.svg",width: 22,height: 22,color: appGreyColor,),
                    const SizedBox(width: 8,),
                    Text("Cart List",style: mediumBlackTextStyle.copyWith(color: notifire!.getMainText),),
                    const Spacer(),
                    Text("Clear",style: mediumBlackTextStyle.copyWith(color: appMainColor),),
                  ],
                ),

                ListView.builder(
                  itemCount: 4,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        const SizedBox(height: 40,),
                        Row(
                          children: [
                            Expanded(child: Text("Roadster Men Navy Solid Round",style: mediumBlackTextStyle.copyWith(color: notifire!.getTextColor1),maxLines: 2,overflow: TextOverflow.ellipsis,)),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  borderRadius:BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.withOpacity(0.3))
                              ),
                              child: const Icon(Icons.delete,color: appGreyColor,size: 18),
                            )
                          ],
                        ),
                        const SizedBox(height: 15,),
                        Row(
                          children: [
                            Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                  borderRadius:BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.withOpacity(0.3))
                              ),
                              padding: const EdgeInsets.all(8),
                              child:  Text("M",style: mediumGreyTextStyle),
                            ),

                            const SizedBox(width:  8,),
                            Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                  borderRadius:BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.withOpacity(0.3))
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Container(
                                height: 15,
                                width: 15,
                                decoration: BoxDecoration(
                                    color: Colors.brown,
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15,),
                        Row(
                          children: [
                            Container(
                              height: 35,
                              width: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.withOpacity(0.3)),
                              ),
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                        onTap: (){
                                          setState(() {
                                            counter++;
                                          });
                                        },
                                        child: Text("+",style: mediumGreyTextStyle.copyWith( fontSize: 16),)),
                                    const SizedBox(width: 8,),
                                    Text(counter.toString(),style: mediumBlackTextStyle.copyWith(fontSize: 18,color: notifire!.getTextColor1),),
                                    const SizedBox(width: 8,),
                                    InkWell(
                                        onTap: () {
                                          if(counter>0){
                                            setState(() {
                                              counter--;
                                            });
                                          }
                                        },
                                        child: Text("-",style: mediumGreyTextStyle.copyWith(fontSize: 16),)),
                                  ]),
                            ),
                            const Spacer(),
                            Text("\$${index+1}9${index+2}",style: mediumBlackTextStyle.copyWith(color: notifire!.getTextColor1,fontSize: 18),)
                          ],
                        )
                      ],
                    );
                  },),


                const SizedBox(height: 25,),
                Divider(height: 40,color: Colors.grey.withOpacity(0.3),),
                Row(
                  children: [
                    Text("Subtotal",style: mediumGreyTextStyle,),
                    const Spacer(),
                    Text("\$400",style: mediumBlackTextStyle.copyWith(color: notifire!.getTextColor1),),
                  ],
                ),
                const SizedBox(height: 12,),
                Row(
                  children: [
                    Text("Text",style: mediumGreyTextStyle,),
                    const Spacer(),
                    Text("\$400",style: mediumBlackTextStyle.copyWith(color: notifire!.getTextColor1),),
                  ],
                ),
                const SizedBox(height: 12,),
                Row(
                  children: [
                    Text("Discount",style: mediumGreyTextStyle,),
                    const Spacer(),
                    Text("\$400",style: mediumBlackTextStyle.copyWith(color: notifire!.getTextColor1),),
                  ],
                ),
                Divider(height: 40,color: Colors.grey.withOpacity(0.3),),
                Row(
                  children: [
                    Text("Total",style: mediumGreyTextStyle.copyWith(fontSize: 16),),
                    const Spacer(),
                    Text("\$400",style: mediumBlackTextStyle.copyWith(color: notifire!.getTextColor1,fontSize: 16),),
                  ],
                ),
                const SizedBox(height: 12,),




              ]),
        ),),
    );
}

  Widget _buildcategory ({required double maxWidth}){
    return SizedBox(
      width: 200,
      child:  Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0,vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(
                          Radius.circular(12)),
                      color: notifire!.getcontiner,
                      boxShadow: boxShadow,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Category",style: mainTextStyle.copyWith(color: notifire!.getMainText),),
                          const SizedBox(height: 10,),
                          SizedBox(
                            height: 80,
                            width: Get.width*0.7,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: category.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        selectCategory =index;
                                      });

                                    },
                                    child: Container(
                                      height: 60,
                                      width: 150,
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.all(Radius.circular(12)),
                                          border: Border.all(color: selectCategory==index? appMainColor : Colors.grey.withOpacity(0.3))),
                                      child:  Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(category[index],style: mediumBlackTextStyle.copyWith(color: notifire!.getMainText),),
                                          const SizedBox(height: 8,),
                                          Text("4${index}1${index+2} Product",style: mediumGreyTextStyle),

                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          // _builddropdown(),
          // _buildsearchbar(size: constraints.maxWidth),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: _buildgridview(width: maxWidth),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildComunContiner() {
    return Container(
      height: 22,
      width: 5,
      color: appMainColor,
    );
  }

  Widget _buildLayoutSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: padding),
      child: Row(
        children: [
          // _buildlayouticon(icon: 'assets/grid-square-circle.svg'),
          // const SizedBox(width: 5,),
          // _buildlayouticon(icon: 'assets/list.svg'),
          // const SizedBox(width: 15,),
          _buildlayout1(),
          const SizedBox(
            width: 15,
          ),
          _buildlayout2(),
          const SizedBox(
            width: 15,
          ),
          _buildlayout3(),
          const SizedBox(
            width: 15,
          ),
          _buildlayout4(),
        ],
      ),
    );
  }

  Widget _buildLayoutSelection3() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: padding),
      child: Row(
        children: [
          // _buildlayouticon(icon: 'assets/grid-square-circle.svg'),
          // const SizedBox(width: 5,),
          // _buildlayouticon(icon: 'assets/list.svg'),
          // const SizedBox(width: 15,),
          _buildlayout1(),
          const SizedBox(
            width: 15,
          ),
          _buildlayout2(),
          const SizedBox(
            width: 15,
          ),
          _buildlayout3()
        ],
      ),
    );
  }

  Widget _buildLayoutSelectiontab() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          // _buildlayouticon(icon: 'assets/grid-square-circle.svg'),
          //
          // const SizedBox(width: 5,),
          //
          // _buildlayouticon(icon: 'assets/list.svg'),
          //
          // const SizedBox(width: 15,),

          _buildlayout1(),

          const SizedBox(
            width: 15,
          ),

          _buildlayout2(),
        ],
      ),
    );
  }

  Widget _buildLayoutSelectionphon() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        PopupMenuButton(
          color: notifire!.getcontiner,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300)),
          shadowColor: Colors.grey.withOpacity(0.3),
          offset: const Offset(-16, 55),
          icon: _buildlayouticon(icon: 'assets/grid-square-circle.svg'),
          itemBuilder: (ctx) => [
            PopupMenuItem(
              enabled: false,
              child: Row(
                children: [
                  InkWell(
                      onTap: () {
                        controller.gridcounter.value = 1;
                        Get.back();
                      },
                      child: _buildlayouticon(icon: 'assets/list.svg')),
                  const SizedBox(
                    width: 10,
                  ),
                  InkWell(
                    onTap: () {
                      controller.gridcounter.value = 2;
                      Get.back();
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildComunContiner(),
                        const SizedBox(
                          width: 2,
                        ),
                        _buildComunContiner()
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _builddropdown() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const SizedBox(
          height: 30,
        ),
        Text(
          "Showing Products 1 - 24 Of 200 Results",
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: notifire!.getMainText),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(
          width: 15,
        ),
        _buildbropdown(),
        const SizedBox(
          width: 12,
        ),
      ],
    );
  }

  Widget _buildLayoutSelectionmobile() {
    return Padding(
      padding: const EdgeInsets.all(padding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildbropdown(),
              const SizedBox(
                width: 5,
              ),
              Flexible(
                child: Text(
                  "Showing Products 1 - 24 Of 200 Results",
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: notifire!.getMainText),
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildlayouticon({required String icon}) {
    return SizedBox(
      height: 40,
      width: 40,
      child: Center(
          child: SvgPicture.asset(
        icon,
        height: 15,
        width: 15,
        color: notifire!.geticoncolor,
      )),
    );
  }

  Widget _buildlayout1() {
    return InkWell(
      onTap: () {
        controller.gridcounter.value = 2;
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildComunContiner(),
          const SizedBox(
            width: 2,
          ),
          _buildComunContiner()
        ],
      ),
    );
  }

  Widget _buildlayout2() {
    return InkWell(
      onTap: () {
        controller.gridcounter.value = 3;
      },
      child: Row(
        children: [
          _buildComunContiner(),
          const SizedBox(
            width: 2,
          ),
          _buildComunContiner(),
          const SizedBox(
            width: 2,
          ),
          _buildComunContiner()
        ],
      ),
    );
  }

  Widget _buildlayout3() {
    return InkWell(
      onTap: () {
        controller.gridcounter.value = 4;
      },
      child: Row(
        children: [
          _buildComunContiner(),
          const SizedBox(
            width: 2,
          ),
          _buildComunContiner(),
          const SizedBox(
            width: 2,
          ),
          _buildComunContiner(),
          const SizedBox(
            width: 2,
          ),
          _buildComunContiner(),
          const SizedBox(
            width: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildlayout4() {
    return InkWell(
      onTap: () {
        controller.gridcounter.value = 5;
      },
      child: Row(
        children: [
          _buildComunContiner(),
          const SizedBox(
            width: 2,
          ),
          _buildComunContiner(),
          const SizedBox(
            width: 2,
          ),
          _buildComunContiner(),
          const SizedBox(
            width: 2,
          ),
          _buildComunContiner(),
          const SizedBox(
            width: 2,
          ),
          _buildComunContiner(),
          const SizedBox(
            width: 2,
          ),
          _buildComunContiner(),
        ],
      ),
    );
  }

  Widget _buildbropdown() {
    return Container(
      width: 136,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        color: notifire!.getcontiner,
        boxShadow: boxShadow,
      ),
      child: DropdownButtonFormField<String>(
        padding: const EdgeInsets.only(left: 10),
        value: selectedOption1,
        dropdownColor: notifire!.getcontiner,
        items: dropdownOptions1.map((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option, style: TextStyle(color: notifire!.getMainText)),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            selectedOption1 = newValue;
          });
        },
        decoration: InputDecoration(
          hintStyle: TextStyle(color: notifire!.getMainText, fontSize: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildsearchbar({required double size}) {
    return Row(
      children: [
        Expanded(
          flex: size < 500 ? 2 : 1,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                color: notifire!.getcontiner,
                boxShadow: boxShadow,
              ),
              child: size < 1000
                  ? _buildLayoutSelectionphon()
                  : size < 1250
                      ? _buildLayoutSelectiontab()
                      : size < 1540
                          ? _buildLayoutSelection3()
                          : _buildLayoutSelection(),
            ),
          ),
        ),
        Expanded(
          flex: size < 500 ? 5 : 7,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              height: 60,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                color: notifire!.getcontiner,
                boxShadow: boxShadow,
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintStyle: TextStyle(color: notifire!.getMainText),
                  hintText: 'Search...',
                  border: InputBorder.none,
                  suffixIcon: Icon(Icons.search, color: notifire!.geticoncolor),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildgridview({required double width}) {
    return Obx(() {
      return GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: controller.gridcounter.value, mainAxisExtent: 450),
        itemCount: controller.prodectname.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(padding),
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                color: notifire!.getcontiner,
                boxShadow: boxShadow,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: InkWell(
                        onTap: () {},
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              // color: Colors.deepPurple,
                              height: 500,
                              width: 400,
                              decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12)),
                                  image: DecorationImage(
                                    image: AssetImage(
                                        controller.productimage[index]),
                                    fit: BoxFit.cover,
                                  )),
                            ),
                            HoverAndPopup(
                              image: controller.productimage[index],
                              name: controller.prodectname[index],
                              price: controller.prodectprice[index],
                              width: width,
                            ),
                          ],
                        )),
                  ),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 100,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RatingBar.builder(
                              initialRating: 3,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemSize: 22,
                              itemBuilder: (context, _) => const Icon(
                                  Icons.star,
                                  color: Color(0xffffa800)),
                              onRatingUpdate: (rating) {},
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(controller.prodectname[index],
                                style: mainTextStyle.copyWith(
                                    fontSize: 17, color: notifire!.getMainText),
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(
                              height: 3,
                            ),
                            Text(controller.prodectdiscription[index],
                                style:
                                    mediumGreyTextStyle.copyWith(fontSize: 13),
                                overflow: TextOverflow.ellipsis),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(controller.prodectprice[index],
                                style: mainTextStyle
                                    .copyWith(fontSize: 17)
                                    .copyWith(color: appMainColor),
                                overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}
