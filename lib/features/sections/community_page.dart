import 'package:flutter/material.dart';
import 'section_components.dart';

class CommunityPage extends StatelessWidget {
 const CommunityPage({super.key,required this.onNavigate}); final ValueChanged<int> onNavigate;
 @override Widget build(BuildContext context)=>SectionFrame(title:'Comunidades',selected:1,onNavigate:onNavigate,children:[
  const _SearchBox(),const SizedBox(height:12),const CategoryChips(['Todas','Frontend','Backend','Móvil','Inteligencia']),
  const SectionHeading('Mis Canales Activos',action:'4 CANALES'),const HorizontalCards(items:[('JS','#javascript','Carlos: ¿alguien vio el PR?','+18'),('Py','#python-ai','Lucia: Nuevo fine-tune listo','+5')]),
  const SectionHeading('Comunidades Destacadas',action:'Top Signal'),
  const SectionCard(title:'JavaScript Masters',subtitle:'34.2k miembros  •  1.8k en línea\nEl ecosistema JS definitivo: TypeScript, React, Node y frameworks modernos.\n#dudas    #showcase    #recursos',icon:Icons.javascript,trailing:Icon(Icons.verified,color:Colors.lightBlue)),
  const SectionCard(title:'Python & Data Science',subtitle:'28.7k miembros  •  2.1k en línea\nComunidad dedicada a Python, Machine Learning, FastAPI y análisis de datos.\n#machine-learning    #proyectos',icon:Icons.data_object),
  const SectionCard(title:'React & Next.js Pro',subtitle:'22.5k miembros  •  940 en línea\nArquitectura de interfaces, estado global y Server Components.\n#nextjs    #server-actions',icon:Icons.bubble_chart),
  const SectionCard(title:'Flutter & Dart Mobile',subtitle:'15.1k miembros  •  620 en línea\nDesarrollo móvil multiplataforma con widgets reactivos.\n#bloc-riverpod    #animaciones',icon:Icons.phone_android),
  const SectionCard(title:'Laravel & PHP Moderno',subtitle:'12.4k miembros  •  410 en línea\nAPIs robustas, arquitectura limpia y testing en backend moderno.',icon:Icons.storage),
  const SectionHeading('Eventos y Hackathons',action:'Ver agenda'),
  const SectionCard(title:'AI Agents & Local LLMs',subtitle:'18 NOV  •  HACKATHON VIRTUAL 48H\nSábado · 14:00 UTC  •  \$5,000 en premios',icon:Icons.event),
  const SectionCard(title:'Rust para Desarrolladores JS',subtitle:'22 NOV  •  WORKSHOP EN VIVO',icon:Icons.event),
 ]);
}
class _SearchBox extends StatelessWidget {const _SearchBox(); @override Widget build(BuildContext c)=>Container(height:48,padding:const EdgeInsets.symmetric(horizontal:13),decoration:BoxDecoration(color:const Color(0xFF102337),borderRadius:BorderRadius.circular(13)),child:const Row(children:[Icon(Icons.search,color:Colors.blueGrey),SizedBox(width:8),Text('Buscar servidores, canales o tags...',style:TextStyle(fontSize:12,color:Colors.blueGrey))]));}
