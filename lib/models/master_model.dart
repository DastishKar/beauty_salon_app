// lib/models/master_model.dart

import 'package:flutter/material.dart';

class MasterModel {
  final String id;
  final String userId;
  final String displayName;
  final List<String> specializations;
  final String experience;
  final Map<String, String> description;
  final String? photoURL;
  final List<String> portfolio;
  final Map<String, DaySchedule> schedule;
  final double rating;
  final int reviewsCount;

  MasterModel({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.specializations,
    required this.experience,
    required this.description,
    this.photoURL,
    List<String>? portfolio,
    Map<String, DaySchedule>? schedule,
    this.rating = 0.0,
    this.reviewsCount = 0,
  }) : 
    portfolio = portfolio ?? [],
    schedule = schedule ?? {};

  String getLocalizedDescription(String languageCode) {
    return description[languageCode] ?? description['ru'] ?? '';
  }

  factory MasterModel.fromMap(String id, Map<String, dynamic> data) {
  // Safely parse schedule with null checking
  Map<String, DaySchedule> scheduleMap = {};
  
  try {
    if (data['schedule'] != null && data['schedule'] is Map) {
      (data['schedule'] as Map).forEach((day, value) {
        if (value != null && value is Map) {
          List<TimeBreak> breaks = [];
          
          // Safely access breaks with null checking
          if (value['breaks'] != null && value['breaks'] is List) {
            for (var breakItem in value['breaks']) {
              if (breakItem is Map && breakItem['start'] != null && breakItem['end'] != null) {
                breaks.add(TimeBreak(
                  start: breakItem['start'].toString(),
                  end: breakItem['end'].toString(),
                ));
              }
            }
          }
          
          // Only add valid schedule entries
          if (value['start'] != null && value['end'] != null) {
            scheduleMap[day.toString()] = DaySchedule(
              start: value['start'].toString(),
              end: value['end'].toString(),
              breaks: breaks,
            );
          }
        }
      });
    }
  } catch (e) {
    debugPrint('Error parsing master schedule: $e');
  }

  return MasterModel(
    id: id,
    userId: data['userId'] ?? '',
    displayName: data['displayName'] ?? '',
    specializations: List<String>.from(data['specializations'] ?? []),
    experience: data['experience'] ?? '',
    description: Map<String, String>.from(data['description'] ?? {}),
    photoURL: data['photoURL'],
    portfolio: List<String>.from(data['portfolio'] ?? []),
    schedule: scheduleMap,
    rating: (data['rating'] ?? 0.0).toDouble(),
    reviewsCount: data['reviewsCount'] ?? 0,
  );
}

    

  Map<String, dynamic> toMap() {
    // Преобразование расписания в Map
    Map<String, dynamic> scheduleMap = {};
    schedule.forEach((day, daySchedule) {
      List<Map<String, String>> breaksMap = [];
      for (var breakItem in daySchedule.breaks) {
        breaksMap.add({
          'start': breakItem.start,
          'end': breakItem.end,
        });
      }
      
      scheduleMap[day] = {
        'start': daySchedule.start,
        'end': daySchedule.end,
        'breaks': breaksMap,
      };
    });

    return {
      'userId': userId,
      'displayName': displayName,
      'specializations': specializations,
      'experience': experience,
      'description': description,
      'photoURL': photoURL,
      'portfolio': portfolio,
      'schedule': scheduleMap,
      'rating': rating,
      'reviewsCount': reviewsCount,
    };
  }

  MasterModel copyWith({
    String? userId,
    String? displayName,
    List<String>? specializations,
    String? experience,
    Map<String, String>? description,
    String? photoURL,
    List<String>? portfolio,
    Map<String, DaySchedule>? schedule,
    double? rating,
    int? reviewsCount,
  }) {
    return MasterModel(
      id: id,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      specializations: specializations ?? List<String>.from(this.specializations),
      experience: experience ?? this.experience,
      description: description ?? Map<String, String>.from(this.description),
      photoURL: photoURL ?? this.photoURL,
      portfolio: portfolio ?? List<String>.from(this.portfolio),
      schedule: schedule ?? Map<String, DaySchedule>.from(this.schedule),
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
    );
  }
}

class DaySchedule {
  final String start;
  final String end;
  final List<TimeBreak> breaks;

  DaySchedule({
    required this.start,
    required this.end,
    List<TimeBreak>? breaks,
  }) : breaks = breaks ?? [];
}

class TimeBreak {
  final String start;
  final String end;

  TimeBreak({
    required this.start,
    required this.end,
  });
}