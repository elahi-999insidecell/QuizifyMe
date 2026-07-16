import 'dart:convert';

CategoryResponseModel categoryResponseModelFromJson(String str) => CategoryResponseModel.fromJson(json.decode(str));

String categoryResponseModelToJson(CategoryResponseModel data) => json.encode(data.toJson());

class CategoryResponseModel {
    List<TriviaCategory>? triviaCategories;

    CategoryResponseModel({
        this.triviaCategories,
    });

    CategoryResponseModel copyWith({
        List<TriviaCategory>? triviaCategories,
    }) => 
        CategoryResponseModel(
            triviaCategories: triviaCategories ?? this.triviaCategories,
        );

    factory CategoryResponseModel.fromJson(Map<String, dynamic> json) => CategoryResponseModel(
        triviaCategories: json["trivia_categories"] == null ? [] : List<TriviaCategory>.from(json["trivia_categories"]!.map((x) => TriviaCategory.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "trivia_categories": triviaCategories == null ? [] : List<dynamic>.from(triviaCategories!.map((x) => x.toJson())),
    };
}

class TriviaCategory {
    int? id;
    String? name;

    TriviaCategory({
        this.id,
        this.name,
    });

    TriviaCategory copyWith({
        int? id,
        String? name,
    }) => 
        TriviaCategory(
            id: id ?? this.id,
            name: name ?? this.name,
        );

    factory TriviaCategory.fromJson(Map<String, dynamic> json) => TriviaCategory(
        id: json["id"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
    };
}
