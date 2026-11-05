import 'package:flutter/material.dart';
import 'section_components.dart';

class CoursesPage extends StatelessWidget {
 const CoursesPage({super.key,required this.onNavigate}); final ValueChanged<int> onNavigate;
 @override Widget build(BuildContext context)=>SectionFrame(title:'Cursos',selected:2,onNavigate:onNavigate,children:[
  const CategoryChips(['Todos','TypeScript','Python','Go','Rust']),
  Container(height:300,margin:const EdgeInsets.only(top:14,bottom:18),padding:const EdgeInsets.all(18),decoration:BoxDecoration(borderRadius:BorderRadius.circular(18),gradient:const LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:[Color(0xFF142440),Color(0xFF063549),Color(0xFF10192E)])),child:const Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisAlignment:MainAxisAlignment.end,children:[Text('🔥 TOP 1 DE LA SEMANA   Avanzado',style:TextStyle(color:Colors.cyanAccent,fontSize:10)),SizedBox(height:14),Text('Master en Arquitectura Cloud & Kubernetes 2025',style:TextStyle(fontSize:25,height:1.1,fontWeight:FontWeight.w900)),SizedBox(height:10),Text('Elena Rojas (Principal SRE)  •  ★ 4.9 (2.4k reseñas)\n◷ 18h 30m',style:TextStyle(fontSize:10,height:1.6)),SizedBox(height:13),_ContinueButton() ])),
  const SectionHeading('Continuar Viendo',action:'Ver historial ›'),const HorizontalCards(items:[('▶','Fullstack Next.js 15 & TypeScript','Módulo 4 · 68% completado','68%'),('Py','Machine Learning práctico','Módulo 2 · 34% completado','34%')]),
  const SectionHeading('Recomendados para ti',action:'Explorar todos ›'),
  const SectionCard(title:'Rust desde Cero a...',subtitle:'☆ 4.8  •  12h\nAprende Borrow Checker, concurrencia sin miedo y desarrollo de servicios.',icon:Icons.memory),
  const SectionCard(title:'Frontend Moderno',subtitle:'☆ 4.9  •  8h\nConstruye interfaces web rápidas, accesibles y listas para producción.',icon:Icons.web),
  const SectionHeading('Inteligencia Artificial y Modelos LLM'),
  const SectionCard(title:'Construcción de Agentes con LangChain',subtitle:'MULTI-AGENT SYSTEMS  •  16h\nAprende a orquestar agentes colaborativos con memoria vectorial.',icon:Icons.hub),
  const SectionCard(title:'Fine-Tuning de LLMs',subtitle:'NUEVO TRACK  •  9h\nEntrena modelos especializados con tus propios datos.',icon:Icons.auto_awesome),
  const SectionHeading('Desarrollo Móvil con Flutter & Swift'),
  const SectionCard(title:'SwiftUI & Arquitectura iOS',subtitle:'Intermedio  •  20h\nDomina SwiftData y concurrencia moderna.',icon:Icons.phone_iphone),
  const SectionCard(title:'Flutter 3.x',subtitle:'Principiante  •  22h\nDesarrollo nativo multiplataforma con Dart.',icon:Icons.flutter_dash),
 ]);
}
class _ContinueButton extends StatelessWidget {const _ContinueButton();@override Widget build(BuildContext c)=>FilledButton.icon(onPressed:()=>ScaffoldMessenger.of(c).showSnackBar(const SnackBar(content:Text('Curso de demostración'))),icon:const Icon(Icons.play_arrow),label:const Text('Continuar Viendo'),style:FilledButton.styleFrom(backgroundColor:const Color(0xFF8146F5)));}
