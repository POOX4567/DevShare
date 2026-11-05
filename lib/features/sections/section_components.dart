import 'package:flutter/material.dart';

import '../../app/app_theme.dart';

const sectionNames = ['Inicio', 'Comunidades', 'Cursos', 'Mensajes', 'Perfil'];

class SectionFrame extends StatelessWidget {
  const SectionFrame({super.key, required this.title, required this.selected, required this.onNavigate, required this.children});
  final String title;
  final int selected;
  final ValueChanged<int> onNavigate;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.navy,
    body: SafeArea(bottom: false, child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 620), child: Column(children: [
      SizedBox(height: 54, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 15), child: Row(children: [const Icon(Icons.code, color: AppColors.cyan), const SizedBox(width: 8), Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('DevShare', style: TextStyle(fontWeight: FontWeight.w800)), Text(title.toUpperCase(), style: const TextStyle(fontSize: 9, color: AppColors.cyan, letterSpacing: 1.1))])), const Icon(Icons.search), const SizedBox(width: 15), const Icon(Icons.notifications_none), const SizedBox(width: 12), const CircleAvatar(radius: 15, backgroundColor: AppColors.violet, child: Text('A'))]))),
      Expanded(child: ListView(padding: const EdgeInsets.all(12), children: children)),
    ])))),
    bottomNavigationBar: Container(height: 62, color: const Color(0xFF071422), child: SafeArea(top: false, child: Row(children: [for (var i=0;i<sectionNames.length;i++) Expanded(child: InkWell(onTap: ()=>onNavigate(i), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon([Icons.terminal,Icons.forum_outlined,Icons.play_circle_outline,Icons.chat_bubble_outline,Icons.code][i], size: 18, color: i==selected?const Color(0xFFD9B7FF):Colors.blueGrey), Text(sectionNames[i], style: TextStyle(fontSize: 8,color: i==selected?const Color(0xFFE0C8FF):Colors.white70))])))]))),
  );
}

class SectionCard extends StatelessWidget {
  const SectionCard({super.key, required this.title, required this.subtitle, this.icon=Icons.code, this.trailing});
  final String title, subtitle;
  final IconData icon;
  final Widget? trailing;
  @override
  Widget build(BuildContext context)=>Container(margin: const EdgeInsets.only(bottom:10),padding: const EdgeInsets.all(14),decoration: BoxDecoration(color:AppColors.panel,borderRadius:BorderRadius.circular(15)),child:Row(children:[Container(width:40,height:40,decoration:BoxDecoration(color:AppColors.field,borderRadius:BorderRadius.circular(10)),child:Icon(icon,color:AppColors.cyan)),const SizedBox(width:10),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontWeight:FontWeight.w800,fontSize:14)),const SizedBox(height:4),Text(subtitle,style:const TextStyle(fontSize:10,color:Color(0xFFB9C7D6)))])),if(trailing != null) trailing!]));
}

class SectionHeading extends StatelessWidget {
  const SectionHeading(this.title,{super.key,this.action}); final String title; final String? action;
  @override Widget build(BuildContext context)=>Padding(padding:const EdgeInsets.symmetric(vertical:9),child:Row(children:[Expanded(child:Text(title,style:const TextStyle(fontWeight:FontWeight.w800,fontSize:16))),if(action!=null)Text(action!,style:const TextStyle(color:AppColors.cyan,fontSize:9))]));
}

class HorizontalCards extends StatelessWidget {
  const HorizontalCards({super.key,required this.items}); final List<(String,String,String,String)> items;
  @override Widget build(BuildContext context)=>SizedBox(height:112,child:ListView(scrollDirection:Axis.horizontal,children:[for(final item in items)Container(width:205,margin:const EdgeInsets.only(right:9),padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:AppColors.panel,borderRadius:BorderRadius.circular(14)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(item.$1,style:const TextStyle(color:AppColors.cyan,fontWeight:FontWeight.w800)),const Spacer(),Text(item.$2,style:const TextStyle(fontWeight:FontWeight.w700)),Text(item.$3,maxLines:1,overflow:TextOverflow.ellipsis,style:const TextStyle(fontSize:10,color:Color(0xFFB9C7D6))),Text(item.$4,style:const TextStyle(fontSize:9,color:AppColors.cyan))]))]));
}

class CategoryChips extends StatelessWidget {
 const CategoryChips(this.items,{super.key}); final List<String> items;
 @override Widget build(BuildContext context)=>SingleChildScrollView(scrollDirection:Axis.horizontal,child:Row(children:[for(var i=0;i<items.length;i++)Container(margin:const EdgeInsets.only(right:7),padding:const EdgeInsets.symmetric(horizontal:13,vertical:8),decoration:BoxDecoration(color:i==0?AppColors.violet:AppColors.panel,borderRadius:BorderRadius.circular(20)),child:Text(items[i],style:const TextStyle(fontSize:10,fontWeight:FontWeight.w700)))]));
}
