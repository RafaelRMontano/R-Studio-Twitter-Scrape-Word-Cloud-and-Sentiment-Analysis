# BMI & Nutrition Calculator

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
      </ul>
    </li>
    <li>
      <a href="#getting-started">Getting Started</a>
      </ul>
    </li>
    <li><a href="#twitter-api-setup">Twitter API Setup</a></li>
    <li>
      <a href="#nutrition-calculator">Nutrition Calculator</a>
      <ul>
        <li><a href="#food-entry">Food Entry</a></li>
        <li><a href="#food-list">Food List</a></li>
        <li><a href="#food-record">Food Record</a></li>
      </ul>
    </li>
  </ol>
</details>

## About The Project

This project was built with excel vba and macros. It contains a BMI calculator, along with a nutrtion calculator which generate resuts given the users personal inputs. I made these as a means to record my calories intake in order to help watch my weight and other nutrition stats as I was in the middle of traveling and couldn't maintain my normal eating schedule and workouts. Hope it may help whoever with there personal health research or just curious.


## Getting Started

Make sure you have excel downloaded. If not this should work on the microsofts free online version, the only diffirence is that you cannot edit the vba code there. Make sure macros are enabled in order to run the code.


## BMI Calculator

The first page is the BMI index calculator. There are already example inputs put into place for you to see and change to your personal index. You will then be given the BMI, BMR and AMR corresponding to your inputs along with a weight loss and gain chart. These results will all be in calories

## Nutrition Calculator

### Food Entry

The next page will be where you input the foods you ate. You will see a date on the top left for the given day and you will start with the `Meal/Snack` entry. It will give you a drop down of choices and when chosen you will move along the entries to the right which will all be drop downs as well expect for the `Portion` where you will eat how many of that foot item you item(1 portion = 1 serving so 1 apple portion = 1 apple etc).

Input your calorie goal on the top and fill out the given table and when you are ready you may click one of the two buttons on the top to save the data with or withouth clearing the table.

### Food List

In the `FoodList` table you will see hundred of various food items with there according measurments which equates to 1 portions. If there is a food item on there you wish to add click on the button to add it and a messagebox will popup asking you to input its according information.

### Food Record
In the `DailyRecord` page you will see a table of all the foods items you saved in the food entry page. The information here is then visualized in the `FoodPivot` page . Click the `Reset` button if you wish to start over and have new information displayed.
