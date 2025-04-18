import matplotlib.pyplot as plt
import json, os

def plot_failure_metrics(file_path):
    with open(file_path, 'r') as f:
        data = json.load(f)[:300]

    steps = list(range(1, len(data) + 1))
    num_correct_sympy_formatting = [item['num_correct_sympy_formatting'] for item in data]
    num_correctly_scored = [item['num_correctly_scored'] for item in data]

    num_correctly_scored = [x/y for x, y in zip(num_correctly_scored, num_correct_sympy_formatting)]
    num_correct_sympy_formatting = [x/160 for x in num_correct_sympy_formatting]

    plt.figure(figsize=(10, 5))
    plt.plot(steps, num_correct_sympy_formatting, label='Num Correct Sympy Formatting')
    plt.plot(steps, num_correctly_scored, label='Num Correctly Scored by Judge')
    plt.xlabel('Steps')
    plt.ylabel('Number of Questions')
    plt.title('Failure Metrics for LLM Judge')
    plt.legend()

    file_path_dir = os.path.dirname(file_path)

    plt.savefig(f'{file_path_dir}/failure_metrics.png')
    plt.close()

if __name__ == "__main__":
    failure_metrics_file = '/home/ubuntu/o1-replication-sydney/CustomTinyZero/checkpoints/llmjudge_experiments/r1_distill_7b_ladder_nosympy/failure_metrics.json'

    plot_failure_metrics(failure_metrics_file)