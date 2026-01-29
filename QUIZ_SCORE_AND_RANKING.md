# Quiz – Score, temps et classement mensuel

## 1. Formule score / temps (côté backend)

Le score affiché après un quiz est calculé **côté backend**. Le frontend affiche ce que l’API renvoie dans `POST /quiz/reponses/{quizId}`.

**Formule typique (à confirmer avec le backend) :**

- **Points bruts** = somme des points des questions correctement répondues (`points_earned`).
- **Facteur temps** = coefficient entre 0,5 et 1,5 selon le temps restant (ex. plus il reste de temps, plus le facteur est proche de 1,5).
- **Score final** = `points_earned × time_factor` (ou formule équivalente côté API).

Le frontend attend au minimum dans la réponse :

- `score` (int) – score final
- `time_remaining` (string, ex. `"00:15:30"`) – temps utilisé
- `pourcentage` (number) – taux de réussite
- Optionnel : `total_points`, `points_earned`, `time_factor`, `correct_count`, `wrong_count`, `questions` (détail par question)

---

## 2. Classement mensuel dynamique

- **Endpoint** : `GET /quiz/classement-general-mensuel`
- **Utilisation** :  
  - Onglet **Classement** : liste complète avec noms et scores réels.  
  - Page d’accueil Quiz : **Score total** et **Rang** de l’utilisateur connecté (recherche de l’utilisateur dans ce classement par `user_id`).
- **Rafraîchissement** :  
  - Au chargement de la page Quiz et de l’onglet Classement.  
  - Pull-to-refresh sur la liste des quiz et sur le classement.
- Pas de cache long : les données sont rechargées à chaque entrée / refresh pour rester à jour.

---

## 3. Backend – Champ `has_played` obligatoire

Pour empêcher de rejouer un quiz déjà terminé, le frontend s’appuie sur **`has_played`**.

- **GET /quiz** (liste des quiz) : chaque élément doit inclure `has_played: true/false` selon que l’utilisateur connecté a déjà soumis ses réponses pour ce quiz.
- **GET /quiz/{id}** (détail d’un quiz) : la réponse doit aussi inclure `has_played: true/false`.

Si ces champs sont absents, le frontend suppose `has_played: false` et garde en plus une mise à jour locale après envoi des réponses (`markQuizAsPlayed` + rafraîchissement de la liste) pour limiter le rejeu.

---

## 4. Résumé des modifications frontend (déjà faites)

| Problème | Solution |
|----------|----------|
| Rejouer après avoir fini | Après envoi des réponses : `markQuizAsPlayed(quizId)` + `getAll()`. Conservation de `hasPlayed` après `getAny()` si déjà joué en local. |
| Score total / rang statiques | Chargement de `getMonthRanking()` à l’accueil Quiz ; affichage du score total et du rang de l’utilisateur connecté. |
| Classement avec faux noms/scores | Affichage des vrais `RankingModel` (nom, score, photo, temps si présent) dans la page de classement et sur le podium. |
