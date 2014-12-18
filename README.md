# matlab-print_fig #
A collection of [MATLAB®](http://www.mathworks.com/products/matlab/) functions that aim to simplify saving formatted figures for printing.

## Usage
To print a figure to a file, capture the figure's handle and pass it to the function.
For example, to save a figure to a file named *'figure.png'*:

```matlab
hf = figure;
plot(1:10,1:10);
print_fig(hf, 'figure', 'png');
```

You can also save a figure to multiple files with different extensions at the same time:

```matlab
print_fig(hf, 'figure', {'png', 'eps'});
```

## License
matlab-print_fig is open-sourced software licensed under the [MIT License](http://opensource.org/licenses/MIT). For the full copyright and license information, please view the LICENSE file that was distributed with this source code.