Die Schule möchte alle Prüfungen in 2 Wochen machen. Jeden Tag gibt es 2 Time Slots für Prüfungen, entweder morgens um 9:00 oder nachmittags um 13:00. 

Die constraints zum Problem lauten:

1. Jede Prüfung passiert genau ein mal
2. Jeder Schüler kann nur eine Prüfung gleichzeitig besuchen
3. Räume, wo die Prüfungen stattfinden sollen, haben feste Kapazitäten
4. Manche Schüler sind erlaubt, 25% oder 50% extra Zeit zu haben
5. Manche Schüler brauchen ihren eigenen Raum
6. Manche Prüfungen können nicht / müssen zum gleichen Zeitpunkt passieren
7. Manche Prüfungen sollen nicht am gleichen Tag passieren
8. Jede Prüfung dauert eine Fixe Zeit

Man möchte nun die Prüfungen so zusammensetzen, dass Schüler so viel Zeit zwischen Prüfungen haben, wie möglich. 

Meine Idee es zu modellieren war so:

![Array model](https://raw.githubusercontent.com/April-Hannah-Lena/schoolwork/main/Integer%20Optimization/schedule_array.jpg)

eine 3d Array $x \in \{ 0,1 \}^{d_1 \times d_2 \times d_3}$ mit Achsen [times, exams, rooms], sowie extra Daten:

![constraints model](https://raw.githubusercontent.com/April-Hannah-Lena/schoolwork/main/Integer%20Optimization/constraints_model.jpg)

Um die constraints zu modellieren bin ich wie folgt vorgegangen:
1\. Eine extra Variable y das als Information hält, ob eine Prüfung an einem gegebenen Zeitpunkt passiert (egal in welchem Zimmer)
   $
   1 \geq y_{i,j} \geq x_{i,j,k}, \quad \sum_{k} x_{i,j,k} \geq y_{i,j} \quad \forall i,j
   $
   Ich will dass die Summe über alle Time Slots (Zeilen) für eine gegebene Prüfung (Spalte) $=1$ ist.
   $
   \sum_{i} y_{i,j} = 1 \quad \forall j
   $
   &nbsp; 
2\. $s$ hält die Information ob ein Schüler eine Prüfung besuchen muss, also möchte ich    dass für ein gegebenen Time Slot (Zeile von $x$) und gegebenen Schüler (Spalte von $s$), höchstens einen Match auftritt.
   $\sum_{j} s_{j,l} y_{i,j} \leq 1 \quad \forall i,l$
   &nbsp; 
3\. Die Räume mit Kapazitäten $c$ die in ein gegebenen Time Slot benutzt werden sollen die Anzahl von Schüler die Platz brauchen nicht überschreiten.
   $
   \sum_{j,k} c_k x_{i,j,k} \geq \sum_{l,j} s_{j,l} y_{i,j}
   $
   &nbsp; 

6\. $ y_{i,j} = j_{i,j'} $ falls die Prüfungen $j, j'$ zusammen passieren müssen, $ y_{i,j} + y_{i,j'} \leq 1 $ falls sie nicht zusammen passieren können.
    &nbsp; 
7\. Da es 2 Time Slots pro Tag gibt, ist Tag $i$ = Zeilen $2(i-1) + 1,\ 2(i-1) + 2$ von $y$. Oder, mit Zeilen von $y$:
   $
   \text{falls Prüfungen j,j' nicht am gleichen Tag passieren sollen}
   \begin{cases}
        & y_{i,j} + y_{i+(i+1\, mod\, 2),j'} \leq 1\\
        & y_{i,j} + y_{i-2(i+1\, mod\, 2),j'} \leq 1\\
        & y_{i,j} + y_{i-(i\, mod\, 2),j'} \leq 1\\
        & y_{i,j} + y_{i+2(i\, mod\, 2),j'} \leq 1\\
   \end{cases}
   $
   &nbsp; 

Bzgl constraints 4/5 wollte ich diese besondere prüfungen einfach als extra Spalten zu $x$ hinzufügen. Ich bin mir allerdings nicht sicher wie ich am besten zie Zeit constraints modelliere. 