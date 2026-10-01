# Digital Pet - Name Team

So this is our digital pet app for In-Class Activity 07. You basically take care of a pet by feeding it and playing with it and its hunger goes up over time so you have to keep up with it. We did the undergraduate pathway.

## Team

- Saurav Annepu (sannepu1) - Care Systems. So I did the feed and play and reset logic and the hunger timer and the win and loss stuff and pause/resume.
- Zachari Taylor (zacharitaylor2024-ux) - Pet Personality. He did the pet image and the mood tint and the mood label and the name field and the speech bubble and the animated meters.

## How to run it

    git clone https://github.com/sannepu1/digital_pet.git
    cd digital_pet
    flutter pub get
    flutter run

To check the code and build the APK:

    flutter analyze
    flutter build apk --release

## How the game works

- Happiness and hunger both start at 50 and they always stay between 0 and 100.
- Feed makes hunger go down by 10. Happiness goes up by 10 but if the hunger ends up under 30 then happiness goes down by 20 instead because the pet is kind of overfed.
- Play makes happiness go up by 10 and hunger go up by 5.
- Every 30 seconds hunger goes up by 5. If hunger is already maxed out then happiness drops by 20 instead.
- You win if happiness stays above 80 for 3 minutes straight. If it drops to 80 or lower the timer cancels and starts over.
- You lose if hunger is 100 and happiness is 10 or lower.
- After a win or a loss Feed and Play are disabled until you hit Reset.
- The pet is green and says Happy above 70 and yellow and Neutral from 30 to 70 and red and Unhappy below 30. The mood also shows as text and an icon so it's not just color.

## Advanced features

| Feature | What it does | Learning outcome | Evidence |
|---|---|---|---|
| Session controls (pause/resume) | Pause basically cancels both timers so nothing changes and Resume starts the hunger timer back up. The 3 minute win count starts over when you resume. | Starting timers in initState and cancelling them in dispose | Pause test below, PR #3 |
| Visual polish and accessible motion | The pet has a speech bubble that changes with its state and the meters kind of glide to the new value and the pet gets a little bigger or smaller with its mood. If the device has animations turned off then it all happens instantly. | The UI reads everything from the same state | Mood tests below, PR #4 |

## Tests

So we tested these by hand with the timers set to 5 seconds and then put them back to 30 seconds and 3 minutes for the release build.

| Test | Result |
|---|---|
| Play at 60 happiness and 65 hunger | Went to 70 and 65 |
| Play three more times | Went to 100 and 80, happiness capped at 100 |
| Feed | Hunger down 10 and happiness up 10 |
| Stay above 80 for the win timer | Win, Feed and Play disabled |
| Let hunger max out | Happiness dropped, game over, buttons locked |
| Reset after game over | Back to 50 and 50, timer ticking again |
| Pause then resume | Hunger stopped going up until Resume |
| Happiness 50 | Yellow, Neutral |
| Happiness 80 | Green, Happy |
| Happiness 0 | Red, Unhappy |

## Pet image

assets/pet.png, added by Zachari.

## Issues and pull requests

- Issue #1 Care loop: https://github.com/sannepu1/digital_pet/issues/1
- Issue #2 Pause and resume: https://github.com/sannepu1/digital_pet/issues/2
- PR #3 Care systems by Saurav: https://github.com/sannepu1/digital_pet/pull/3
- PR #4 Pet personality by Zachari, reviewed by Saurav: https://github.com/sannepu1/digital_pet/pull/4
