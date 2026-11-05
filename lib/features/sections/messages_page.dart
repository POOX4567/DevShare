import 'package:flutter/material.dart';
import 'section_components.dart';

class MessagesPage extends StatelessWidget {
 const MessagesPage({super.key,required this.onNavigate}); final ValueChanged<int> onNavigate;
 @override Widget build(BuildContext context)=>SectionFrame(title:'Mensajes',selected:3,onNavigate:onNavigate,children:[
  const _OnlineStatus(),const SizedBox(height:12),const _Search(),const SizedBox(height:12),const CategoryChips(['# Canales de Comunidad','@ Mensajes Directos  3']),
  const SectionHeading('CONECTADOS AHORA',action:'18 online'),const HorizontalCards(items:[('EF','Elena Fox','En live code','●'),('KG','Karlos G.','Viendo Next.js','●'),('SC','Sofia Chen','Online','●')]),
  const SizedBox(height:12),const SectionCard(title:'Sala Pair-Programming #2',subtitle:'EN VIVO\n3 devs en llamada',icon:Icons.graphic_eq,trailing:_JoinButton()),
  const SectionHeading('ACTIVIDAD RECIENTE',action:'Marcar leídos'),
  const SectionCard(title:'# arquitectura-software',subtitle:'JS Masters  ·  4m\nMateo Dev: Revisen el PR #402 con la nueva arquitectura... ',icon:Icons.tag),
  const SectionCard(title:'Sofía Chen',subtitle:'Sr Backend  ·  12m\n¿Tienes 10 mins para pair programming en la API?',icon:Icons.person),
  const SectionCard(title:'# python-machine-learning',subtitle:'AI Hub  ·  25m\nDavid K.: Compartí el notebook con los pesos...',icon:Icons.tag),
  const SectionCard(title:'Equipo Hackathon 2025',subtitle:'4 devs  ·  1h\nLucas: Subí el diagrama a Figma, chequen el flujo.',icon:Icons.groups),
  Row(children:[Expanded(child:OutlinedButton.icon(onPressed:()=>_toast(context,'Crear servidor'),icon:const Icon(Icons.add_circle_outline),label:const Text('Crear Servidor'))),const SizedBox(width:8),Expanded(child:OutlinedButton.icon(onPressed:()=>_toast(context,'Añadir amigo'),icon:const Icon(Icons.person_add_alt_1),label:const Text('Añadir Amigo')))]),
 ]);
}
class _OnlineStatus extends StatelessWidget {const _OnlineStatus();@override Widget build(BuildContext c)=>const Row(children:[CircleAvatar(radius:22,backgroundColor:Color(0xFF20405C),child:Text('AR')),SizedBox(width:9),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Alex Rivera  PRO',style:TextStyle(fontWeight:FontWeight.w800)),Text('● Programando en Rust 💻',style:TextStyle(color:Color(0xFF60D9F6),fontSize:11))])),Icon(Icons.tune)]);}
class _Search extends StatelessWidget {const _Search();@override Widget build(BuildContext c)=>Container(height:46,padding:const EdgeInsets.symmetric(horizontal:12),decoration:BoxDecoration(color:const Color(0xFF102337),borderRadius:BorderRadius.circular(13)),child:const Row(children:[Icon(Icons.search,color:Colors.blueGrey),SizedBox(width:8),Text('Buscar conversaciones, canales o amigos...',style:TextStyle(fontSize:11,color:Colors.blueGrey))]));}
class _JoinButton extends StatelessWidget {const _JoinButton();@override Widget build(BuildContext c)=>FilledButton(onPressed:()=>_toast(c,'Unirse a la sala'),style:FilledButton.styleFrom(backgroundColor:const Color(0xFF8146F5)),child:const Text('Unirme'));}
void _toast(BuildContext c,String text)=>ScaffoldMessenger.of(c).showSnackBar(SnackBar(content:Text('$text estará disponible próximamente.')));
