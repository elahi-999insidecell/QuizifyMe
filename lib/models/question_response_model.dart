
import 'dart:convert';

QuestionResponseModel questionResponseModelFromJson(String str) => QuestionResponseModel.fromJson(json.decode(str));

String questionResponseModelToJson(QuestionResponseModel data) => json.encode(data.toJson());

class QuestionResponseModel {
    int? responseCode;
    List<Result>? results;

    QuestionResponseModel({
        this.responseCode,
        this.results,
    });

    factory QuestionResponseModel.fromJson(Map<String, dynamic> json) => QuestionResponseModel(
        responseCode: json["response_code"],
        results: json["results"] == null ? [] : List<Result>.from(json["results"]!.map((x) => Result.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "response_code": responseCode,
        "results": results == null ? [] : List<dynamic>.from(results!.map((x) => x.toJson())),
    };
}

class Result {
    String? type;
    String? difficulty;
    String? category;
    String? question;
    String? correctAnswer;
    List<String>? incorrectAnswers;

    Result({
        this.type,
        this.difficulty,
        this.category,
        this.question,
        this.correctAnswer,
        this.incorrectAnswers,
    });

    factory Result.fromJson(Map<String, dynamic> json) => Result(
        type: json["type"],
        difficulty: json["difficulty"],
        category: json["category"],
        question: json["question"],
        correctAnswer: json["correct_answer"],
        incorrectAnswers: json["incorrect_answers"] == null ? [] : List<String>.from(json["incorrect_answers"]!.map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "type": type,
        "difficulty": difficulty,
        "category": category,
        "question": question,
        "correct_answer": correctAnswer,
        "incorrect_answers": incorrectAnswers == null ? [] : List<dynamic>.from(incorrectAnswers!.map((x) => x)),
    };
}
